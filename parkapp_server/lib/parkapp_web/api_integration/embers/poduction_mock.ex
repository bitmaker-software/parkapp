defmodule ParkappWeb.ApiIntegration.Embers.ProductionMock do
  @moduledoc """
    Mock implementation of the Embers API. Used for testing in production.
    It proxies the functioning APIs and mocks payment1, payment2 and get_reservation.
  """

  @behaviour ParkappWeb.ApiIntegration.Embers.Behaviour

  alias ParkappWeb.ApiIntegration.Embers.API
  alias Parkapp.ReservationsContext
  alias Parkapp.Reservations.ReservationStatus.Enum, as: ReservationStatusEnum
  use ParkappWeb.ApiIntegration.GenServers.StateSync.PresenceStatus

  def get_route(from, to, mode) do
    API.get_route(from, to, mode)
  end

  def get_reservation(locator) do
    case ReservationsContext.get_reservation_by_locator(locator) do
      nil ->
        :error

      reservation ->
        {:ok,
         %{
           "reservations" => [
             %{
               "product" => %{
                 "barcode" => reservation.barcode,
                 "presence_status" => get_presence_status(reservation)
               },
               "activation" => reservation.reservation_start_time,
               "expiry" => reservation.cancelled_at,
               "cancelled" => reservation.cancelled
             }
           ]
         }}
    end
  end

  defp get_presence_status(reservation) do
    cond do
      reservation.reservation_status_id == ReservationStatusEnum.closed() ->
        @closed

      reservation.reservation_status_id == ReservationStatusEnum.open() ->
        @undefined

      true ->
        @inpark
    end
  end

  def make_reservation(_config) do
    {:ok,
     %{
       "product" => %{
         "barcode" => Ecto.UUID.generate()
       },
       "locator" => Ecto.UUID.generate()
     }}
  end

  def cancel_reservation(locator) do
    case ReservationsContext.get_reservation_by_locator(locator) do
      nil ->
        :error

      reservation ->
        {:ok,
         %{
           "activation" => reservation.reservation_start_time,
           "cancelled" => true,
           "locator" => reservation.locator,
           "product" => %{
             "barcode" => reservation.barcode
           }
         }}
    end
  end

  def delete_reservation(_locator) do
    {:ok, nil}
  end

  def payment1(barcode) do
    reservation = ReservationsContext.get_reservation_by_barcode(barcode)

    {:ok,
     %{
       "context_token" => get_value(reservation, :context_token, "some context token"),
       "parking_start_time" => get_value(reservation, :parking_start_time, DateTime.utc_now()),
       "parking_payment_time" => get_value(reservation, :parking_payment_time),
       "outstanding_amount" => get_value(reservation, :amount, "10.00")
     }}
  end

  defp get_value(reservation, field, default \\ nil)
  defp get_value(nil, _field, default), do: default

  defp get_value(reservation, field, default) when is_atom(field) do
    with(
      field_value <- Map.get(reservation, field),
      false <- is_nil(field_value)
    ) do
      field_value
    else
      _ ->
        default
    end
  end

  def payment2(_context_token) do
    :ok
  end
end
