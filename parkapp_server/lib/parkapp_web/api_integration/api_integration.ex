defmodule ParkappWeb.ApiIntegration do
  @moduledoc """
    This module handles coordination beetween thir party APIs and the server's database
  """

  require Logger

  alias __MODULE__.Embers.Helpers, as: EmbersHelpers
  alias __MODULE__.MBWay.Helpers, as: MBWayHelpers
  alias __MODULE__.MBWay.WebhookData
  alias __MODULE__.Timeout
  alias Parkapp.Reservations.ReservationStatus.Enum, as: ReservationStatusEnum
  alias Parkapp.Reservations.ReservationType.Enum, as: ReservationTypeEnum
  alias Parkapp.Reservations.ReservationType.ConfigurationStruct
  alias Parkapp.ReservationsContext
  alias Parkapp.Logging

  @doc """
    Performs the reservation with the Embers API and updates the databse.
    If anythings go wrong, the reservation is cancelled.
  """
  @spec reserve_single_use(String) :: {:ok, Map} | {:error, Changeset} | {:timeout, String} | nil
  def reserve_single_use(device_id) when is_bitstring(device_id) do
    configuration = ConfigurationStruct.get_configuration(ReservationTypeEnum.single_use())
    reserve(device_id, configuration)
  end

  @doc """
    Performs the reservation with the Embers API and updates the databse.
    If anythings go wrong, the reservation is cancelled.
  """
  @spec book_reservation(String) :: {:ok, Map} | {:error, Changeset} | {:timeout, String} | nil
  def book_reservation(device_id) when is_bitstring(device_id) do
    configuration = ConfigurationStruct.get_configuration(ReservationTypeEnum.booked())
    reserve(device_id, configuration)
  end

  @doc """
    Performs the reservation with the Embers API and updates the databse.
    If anythings go wrong, the reservation is cancelled.
  """
  @spec reserve(String, ConfigurationStruct) ::
          {:ok, Map} | {:error, Changeset} | {:timeout, String} | nil
  defp reserve(device_id, %ConfigurationStruct{} = configuration)
       when is_bitstring(device_id) do
    with(
      reservation <- ReservationsContext.get_current_reservation(device_id),
      true <- is_nil(reservation)
    ) do
      case Timeout.check_time_since_last_cancelled_reservation(device_id) do
        true ->
          with(
            module <- EmbersHelpers.get_api_module(),
            {:ok, result} <- module.make_reservation(configuration),
            locator <- Map.get(result, "locator"),
            barcode <-
              Map.get(result, "product")
              |> Map.get("barcode"),
            reservation_start_time <- DateTime.utc_now()
          ) do
            case ReservationsContext.create_reservation_initial_state(%{
                   device_id: device_id,
                   locator: locator,
                   barcode: barcode,
                   reservation_type_id: configuration.reservation_type,
                   reservation_start_time: reservation_start_time
                 }) do
              {:ok, reservation} ->
                {:ok, reservation}

              error ->
                module.delete_reservation(locator)
                error
            end
          else
            _ ->
              nil
          end

        false ->
          {:timeout, Timeout.get_unban_datetime(device_id)}
      end
    else
      _other ->
        nil
    end
  end

  defp reserve(_device_id, _config), do: nil

  @doc """
    Cancels the active reservation
  """
  @spec cancel_reservation(String) :: {:ok, Map} | {:error, Changeset} | nil
  def cancel_reservation(device_id) when is_bitstring(device_id) do
    with(
      reservation <- ReservationsContext.get_current_reservation(device_id),
      false <- is_nil(reservation),
      module <- EmbersHelpers.get_api_module(),
      {:ok, _result} <- module.cancel_reservation(reservation.locator)
    ) do
      ReservationsContext.cancel_reservation(reservation)
    else
      _other ->
        nil
    end
  end

  @spec payment1(String) :: {:ok, Map} | {:error, Changeset} | nil
  def payment1(device_id) do
    with(
      reservation <- ReservationsContext.get_current_reservation(device_id),
      false <- is_nil(reservation),
      true <- reservation.reservation_status_id == ReservationStatusEnum.in_park(),
      {:ok, result} <- EmbersHelpers.get_api_module().payment1(reservation.barcode),
      context_token <- Map.get(result, "context_token"),
      amount <- Map.get(result, "outstanding_amount"),
      {:ok, reservation} <-
        ReservationsContext.update_reservation_after_payment1(reservation, %{
          context_token: context_token,
          amount: amount,
          payment1_time: DateTime.utc_now()
        })
    ) do
      {:ok, reservation}
    else
      {:error, changeset} ->
        {:error, changeset}

      _ ->
        nil
    end
  end

  @spec pay(String, String) :: {:ok, Map} | {:error, Changeset} | nil | :timeout
  def pay(device_id, phone_number) do
    with(
      reservation <- ReservationsContext.get_current_reservation(device_id),
      false <- is_nil(reservation),
      true <- reservation.reservation_status_id == ReservationStatusEnum.in_park()
    ) do
      with(
        false <- Timeout.check_time_to_pay_timeout(reservation),
        false <- is_nil(reservation.payment1_time)
      ) do
        external_payment(reservation, device_id, phone_number)
      else
        _ ->
          :timeout
      end
    else
      _ ->
        nil
    end
  end

  @doc """
    Handles the external_payment api request + database state transition
  """
  @spec external_payment(Reservation, String, String) :: {:ok, Map} | {:error, Changeset} | nil
  defp external_payment(reservation, device_id, phone_number) do
    with(
      true <- !is_nil(reservation.amount) && !is_nil(reservation.context_token),
      {:ok, _result} <-
        MBWayHelpers.get_api_module().request_payment(device_id, phone_number, reservation.amount),
      {:ok, reservation} <- ReservationsContext.move_to_external_payment_state(reservation)
    ) do
      {:ok, reservation}
    else
      {:error, changeset} ->
        # What to do here?
        {:error, changeset}

      _other ->
        # What to do here?
        nil
    end
  end

  @doc """
    Handles the last steps of the payment workflow after the external payment is successfull
  """
  @spec complete_payment_procedure(WebhookData) :: {:ok, Map} | {:error, Changeset} | nil
  def complete_payment_procedure(nil), do: nil

  def complete_payment_procedure(%WebhookData{} = webhook_data) do
    with(
      module <- EmbersHelpers.get_api_module(),
      reservation <- ReservationsContext.get_current_reservation(webhook_data.device_id),
      false <- is_nil(reservation),
      true <- reservation.reservation_status_id == ReservationStatusEnum.external_payment()
    ) do
      Logging.create_external_payment_log(%{
        reservation_id: reservation.id,
        received_at: DateTime.utc_now(),
        body: webhook_data.body,
        result_code: webhook_data.result_code
      })

      cond do
        WebhookData.validate(webhook_data) == true ->
          Logger.info("valid webhook_data")

          case module.payment2(reservation.context_token) do
            :ok ->
              ReservationsContext.move_to_payment2_state(
                reservation,
                DateTime.utc_now()
              )

            _else ->
              :send_new_notification
          end

        true ->
          if WebhookData.should_revert(webhook_data) do
            Logger.info("reverting to inpark")
            ReservationsContext.revert_from_external_payment_to_in_park(reservation)
          end
      end
    else
      _error ->
        nil
    end
  end
end
