defmodule ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSync do
  @moduledoc """
    Handles the internal state sync with the external APIs
  """

  @behaviour ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSyncBehaviour

  use ParkappWeb.ApiIntegration.GenServers.StateSync.PresenceStatus
  alias ParkappWeb.ApiIntegration.Embers.Helpers, as: EmbersHelpers
  alias ParkappWeb.ApiIntegration.Timeout
  alias Parkapp.ReservationsContext
  alias Parkapp.Reservations.ReservationStatus.Enum, as: ReservationStatusEnum
  alias Parkapp.Reservations.ReservationType.Enum, as: ReservationTypeEnum

  @doc """
  Uses the Embers's API to produce a map of the reservation's attributes
  """
  @spec get_updated_reservation_status(Reservation) :: :noop | Map
  def get_updated_reservation_status(reservation) do
    with(
      {:ok, %{"reservations" => reservations}} <-
        EmbersHelpers.get_api_module().get_reservation(reservation.locator),
      %{
        "product" => %{
          "barcode" => barcode,
          "presence_status" => presence_status
        },
        "activation" => reservation_start_time,
        "expiry" => expiry_time,
        "cancelled" => cancelled
      } <- List.first(reservations)
    ) do
      case verify_state(presence_status, barcode, reservation) do
        :noop ->
          :noop

        sub_attrs ->
          attrs =
            Enum.into(
              sub_attrs,
              %{
                barcode: barcode,
                locator: reservation.locator,
                cancelled: cancelled,
                cancelled_at: get_cancelled_at(cancelled, expiry_time),
                reservation_start_time: reservation_start_time,
                reservation_status_id: ReservationStatusEnum.open()
              }
            )

          cond do
            attrs.cancelled == true ->
              Map.put(attrs, :reservation_status_id, ReservationStatusEnum.closed())

            true ->
              attrs
          end
      end
    else
      _ ->
        :noop
    end
  end

  @doc """
    Determined the cancelled_at value based on the cancelled flag gotten from Embers API
  """
  @spec get_cancelled_at(Boolean, DateTime) :: DateTime | nil
  defp get_cancelled_at(true, expiry_time), do: expiry_time
  defp get_cancelled_at(false, _expiry_time), do: nil

  @doc """
  Helper to validate each possible presence status from Embers
  """
  @spec verify_state(PresenceStatus, String, Reservation) :: :noop | Map
  defp verify_state(@inpark, barcode, old_reservation) do
    case EmbersHelpers.get_api_module().payment1(barcode) do
      {:ok,
       %{
         "parking_start_time" => parking_start_time,
         "parking_payment_time" => parking_payment_time,
         "outstanding_amount" => amount,
         "context_token" => context_token
       }} ->
        with(false <- is_nil(parking_payment_time)) do
          %{
            context_token: context_token,
            amount: amount,
            parking_start_time: parking_start_time,
            parking_payment_time: parking_payment_time,
            payment1_time: parking_payment_time,
            reservation_status_id: ReservationStatusEnum.payment2()
          }
        else
          _ ->
            case Timeout.check_time_to_pay_timeout(old_reservation) do
              true ->
                %{
                  context_token: nil,
                  amount: nil,
                  payment1_time: nil
                }

              false ->
                %{}
            end
            |> Enum.into(%{
              parking_payment_time: nil,
              parking_start_time: parking_start_time,
              reservation_status_id: ReservationStatusEnum.in_park()
            })
        end

      _error ->
        :noop
    end
  end

  defp verify_state(@closed, _barcode, _old_reservation) do
    %{
      reservation_status_id: ReservationStatusEnum.closed()
    }
  end

  defp verify_state(_presece_status, _barcode, old_reservation) do
    with(
      true <- check_open_timeout(old_reservation),
      {:ok, _result} <- EmbersHelpers.get_api_module().cancel_reservation(old_reservation.locator)
    ) do
      %{
        cancelled: true,
        cancelled_at: DateTime.utc_now(),
        reservation_status_id: ReservationStatusEnum.closed()
      }
    else
      _ ->
        %{
          context_token: nil,
          amount: nil,
          payment1_time: nil,
          parking_payment_time: nil,
          parking_start_time: nil
        }
    end
  end

  @doc """
    Pseudo polymorfic timeout funcion selection based on the reservation type
  """
  @spec check_open_timeout(Reservation) :: Boolean
  defp check_open_timeout(reservation) do
    cond do
      reservation.reservation_type_id == ReservationTypeEnum.single_use() ->
        Timeout.check_time_to_enter_park_timeout(reservation)

      reservation.reservation_type_id == ReservationTypeEnum.booked() ->
        Timeout.check_time_to_enter_park_after_booking_timeout(reservation)

      true ->
        false
    end
  end

  @doc """
  Updates the given reservation based on the given attributes.
  If something fails, the old reservation is returned
  """
  @spec get_updated_reservation(Reservation, :noop | Map) :: {:ok, Reservation}
  def get_updated_reservation(reservation, :noop) do
    {:ok, reservation}
  end

  def get_updated_reservation(old_reservation, attrs) when is_map(attrs) do
    with(
      attrs <- correct_attrs(old_reservation, attrs),
      {new_status_id, attrs} <- Map.pop(attrs, :reservation_status_id),
      {:ok, reservation} <- ReservationsContext.update_reservation(old_reservation, attrs),
      {:ok, reservation} <- update_inpark(reservation, attrs),
      {:ok, reservation} <- update_payment1(reservation, attrs),
      {:ok, reservation} <- update_payment2(reservation, attrs)
    ) do
      case ReservationsContext.move_reservation_from_to(
             reservation,
             reservation.reservation_status_id,
             new_status_id
           ) do
        {:ok, moved_reservation} ->
          {:ok, moved_reservation}

        _else ->
          {:ok, reservation}
      end
    else
      _error ->
        {:ok, old_reservation}
    end
  end

  @doc """
  Given the old reservation and the produced attributes, it makes validations of the attributes given the internal reservation state machine
  """
  @spec correct_attrs(Reservation, Map) :: Map
  defp correct_attrs(reservation, attrs) when is_map(attrs) do
    with(
      true <- attrs.reservation_status_id == ReservationStatusEnum.in_park(),
      true <-
        reservation.reservation_status_id in [
          ReservationStatusEnum.external_payment()
        ]
    ) do
      Map.put(attrs, :reservation_status_id, reservation.reservation_status_id)
    else
      _else ->
        attrs
    end
  end

  @doc """
  Tries to update a reservation with the inpark changeset
  If it fails, the old reservation is returned
  """
  @spec update_inpark(Reservation, Map) :: {:ok, Reservation}
  defp update_inpark(old_reservation, attrs) when is_map(attrs) do
    reservation =
      case ReservationsContext.update_reservation_inpark(old_reservation, attrs) do
        {:ok, new_reservation} ->
          new_reservation

        _else ->
          with(
            true <- is_nil(Map.get(attrs, :parking_start_time, "")),
            {:ok, reservation} <- ReservationsContext.revert_in_park_values(old_reservation)
          ) do
            reservation
          else
            _ ->
              old_reservation
          end
      end

    {:ok, reservation}
  end

  @doc """
  Tries to update a reservation with the payment1 changeset
  If it fails, the old reservation is returned
  """
  @spec update_payment1(Reservation, Map) :: {:ok, Reservation}
  defp update_payment1(old_reservation, attrs) when is_map(attrs) do
    reservation =
      case ReservationsContext.update_reservation_after_payment1(old_reservation, attrs) do
        {:ok, new_reservation} ->
          new_reservation

        _else ->
          with(
            true <- is_nil(Map.get(attrs, :context_token, "")),
            true <- is_nil(Map.get(attrs, :amount, "")),
            true <- is_nil(Map.get(attrs, :payment1_time, "")),
            {:ok, reservation} <- ReservationsContext.revert_payment1_values(old_reservation)
          ) do
            reservation
          else
            _ ->
              old_reservation
          end
      end

    {:ok, reservation}
  end

  @doc """
  Tries to update a reservation with the payment2 changeset
  If it fails, the old reservation is returned
  """
  @spec update_payment2(Reservation, Map) :: {:ok, Reservation}
  defp update_payment2(old_reservation, attrs) when is_map(attrs) do
    reservation =
      case ReservationsContext.update_reservation_after_payment2(old_reservation, attrs) do
        {:ok, new_reservation} ->
          new_reservation

        _else ->
          with(
            true <- is_nil(Map.get(attrs, :parking_payment_time, "")),
            {:ok, reservation} <- ReservationsContext.revert_payment2_values(old_reservation)
          ) do
            reservation
          else
            _ ->
              old_reservation
          end
      end

    {:ok, reservation}
  end
end
