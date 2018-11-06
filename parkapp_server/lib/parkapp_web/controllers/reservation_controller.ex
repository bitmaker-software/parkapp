defmodule ParkappWeb.ReservationController do
  @moduledoc """
    The ReservationController handles the reservation related requests.
  """
  use ParkappWeb, :controller

  alias ParkappWeb.Utils
  alias ParkappWeb.Auth
  alias ParkappWeb.ApiIntegration
  alias Parkapp.ReservationsContext

  # Add an error handler controller
  action_fallback(ParkappWeb.FallbackController)

  @doc """
    Returns the payment information relative to the current active reservation.
    Returns 404 if there none is found.
  """
  def get_current_reservation_payment(conn, _params) do
    with(
      device <- Auth.get_current_session_device(conn),
      reservation <- ReservationsContext.get_current_reservation(device.device_id),
      false <- is_nil(reservation)
    ) do
      amount =
        case ApiIntegration.Embers.Helpers.get_api_module().payment1(reservation.barcode) do
          {:ok, %{"outstanding_amount" => amount}} ->
            amount

          _else ->
            nil
        end

      render(conn, ParkappWeb.ReservationView, "reservation_payment.json",
        reservation: reservation,
        amount: amount
      )
    else
      _ ->
        render(conn, ParkappWeb.ReservationView, "reservation_not_found.json")
    end
  end

  @doc """
    Action that performs the reservation
  """
  def reserve(conn, _params) do
    device = Auth.get_current_session_device(conn)

    ApiIntegration.reserve_single_use(device.device_id)
    |> handle_reserve_result(conn)
  end

  @doc """
    Action that performs the reservation
  """
  def book(conn, _params) do
    device = Auth.get_current_session_device(conn)

    ApiIntegration.book_reservation(device.device_id)
    |> handle_reserve_result(conn)
  end

  defp handle_reserve_result(nil, _conn), do: {:bad_request, "Something went wrong"}
  defp handle_reserve_result({:timeout, nil}, _conn), do: {:bad_request, "Something went wrong"}

  defp handle_reserve_result({:timeout, unban_at}, _conn),
    do: {:not_acceptable, "Not able to reserve until #{unban_at}"}

  defp handle_reserve_result({:error, result}, _conn) do
    Logger.warn(Poison.encode!(result))
    {:bad_request, "Invalid parameters"}
  end

  defp handle_reserve_result({:ok, reservation}, conn),
    do: render(conn, ParkappWeb.ReservationView, "reservation.json", reservation: reservation)

  @doc """
    Action that cancels the active reservation
  """
  def cancel_reservation(conn, _params) do
    device = Auth.get_current_session_device(conn)

    case ApiIntegration.cancel_reservation(device.device_id) do
      nil ->
        {:bad_request, "Something went wrong"}

      {:error, result} ->
        Logger.warn(Poison.encode!(result))
        {:bad_request, "Invalid parameters"}

      {:ok, _result} ->
        {:ok, %{}}
    end
  end

  @doc """
    Action that informs the server that the user entered the park
  """
  def in_park(conn, _params) do
    with(
      device <- Auth.get_current_session_device(conn),
      reservation <- ReservationsContext.get_current_reservation(device.device_id),
      false <- is_nil(reservation),
      {:ok, _reservation} <-
        ReservationsContext.move_to_in_park_state(reservation, DateTime.utc_now())
    ) do
      {:ok, %{}}
    else
      {:error, result} ->
        Logger.warn(Poison.encode!(result))
        {:bad_request, "Invalid parameters"}

      _error ->
        {:bad_request, "Something went wrong"}
    end
  end

  @doc """
    Action that updates the payment1 values to be used in the pay action
  """
  def payment1(conn, _params) do
    with(
      device <- Auth.get_current_session_device(conn),
      {:ok, reservation} <- ApiIntegration.payment1(device.device_id)
    ) do
      {:ok, %{amount: reservation.amount}}
    else
      {:error, result} ->
        Logger.warn(Poison.encode!(result))
        {:bad_request, "Invalid parameters"}

      _error ->
        {:bad_request, "Something went wrong"}
    end
  end

  @doc """
    Action that performs the first step in the payment workflow
  """
  def pay(_conn, %{"phone_number" => "null"}) do
    {:bad_request, "Phone number cannot be null"}
  end

  def pay(conn, %{"phone_number" => phone_number}) do
    device = Auth.get_current_session_device(conn)

    case ApiIntegration.pay(device.device_id, phone_number) do
      nil ->
        {:bad_request, "Something went wrong"}

      :timeout ->
        {:not_acceptable, "Payment timeout"}

      {:error, result} ->
        Logger.warn(Poison.encode!(result))
        {:bad_request, "Invalid parameters"}

      {:ok, reservation} ->
        Utils.push_reservation_to_client(reservation)

        {:ok, %{}}
    end
  end

  def pay(_conn, _params) do
    {:generic_unprocessable_entity, "Invalid parameters"}
  end

  @doc """
    Webhook for MBway callback. Finalizes the payment workflow.
  """
  def complete_payment(_conn, %{"encryptedBody" => "null"}) do
    {:bad_request, "Params cannot be null"}
  end

  def complete_payment(conn, %{"encryptedBody" => encrypted_body}) do
    Logger.info(encrypted_body)

    Logger.info(fn ->
      conn.req_headers
      |> Enum.map(fn {key, value} ->
        Map.put_new(%{}, key, value)
      end)
      |> Poison.encode!()
    end)

    with(
      iv_from_http_header <- get_req_header(conn, "x-initialization-vector") |> List.first(),
      auth_tag_from_http_header <- get_req_header(conn, "x-authentication-tag") |> List.first(),
      Logger.info(iv_from_http_header),
      Logger.info(auth_tag_from_http_header),
      decrypt_result <-
        ApiIntegration.MBWay.Helpers.decrypt_hexadecimal_response(
          encrypted_body,
          auth_tag_from_http_header,
          iv_from_http_header
        ),
      {:ok, body} <- Poison.decode("#{decrypt_result}"),
      webhook_data <- ApiIntegration.MBWay.WebhookData.build(body),
      {:ok, reservation} <- ApiIntegration.complete_payment_procedure(webhook_data)
    ) do
      Utils.push_reservation_to_client(reservation)
      # {:ok, %{}}
      send_resp(conn, :ok, "")
    else
      :send_new_notification ->
        Logger.error("send_new_notification")
        # only return an error if the payment2 API failed.
        send_resp(conn, :bad_gateway, "")

      _error ->
        Logger.error("complete_payment error")
        # {:bad_request, "Something went wrong"}
        send_resp(conn, :ok, "")
    end
  end

  def complete_payment(_conn, params) do
    Logger.error(Kernel.inspect(params))
    {:generic_unprocessable_entity, "Invalid parameters"}
  end

  @doc """
    Action that informs the server that the user left the park
  """
  def close(conn, _params) do
    with(
      device <- Auth.get_current_session_device(conn),
      reservation <- ReservationsContext.get_current_reservation(device.device_id),
      false <- is_nil(reservation),
      {:ok, _reservation} <- ReservationsContext.move_to_closed_state(reservation)
    ) do
      {:ok, %{}}
    else
      {:error, result} ->
        Logger.warn(Poison.encode!(result))
        {:bad_request, "Invalid parameters"}

      _error ->
        {:bad_request, "Something went wrong"}
    end
  end
end
