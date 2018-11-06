defmodule ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSyncOpenBookedTimeoutMock do
  @moduledoc """
    Mocks the timeout that occurs when a user booked a spot in the park but took too long to enter
  """

  @behaviour ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSyncBehaviour

  @doc """
  Either returns :noop or it returns returns a map once the timeout happens
  """
  def get_updated_reservation_status(reservation) do
    with(
      true <-
        reservation.reservation_type_id == Parkapp.Reservations.ReservationType.Enum.booked(),
      true <-
        ParkappWeb.ApiIntegration.Timeout.check_time_to_enter_park_after_booking_timeout(
          reservation
        )
    ) do
      %{
        barcode: reservation.barcode,
        locator: reservation.locator,
        cancelled: true,
        cancelled_at: DateTime.utc_now(),
        reservation_start_time: reservation.reservation_start_time,
        reservation_status_id: Parkapp.Reservations.ReservationStatus.Enum.closed()
      }
    else
      _ ->
        :noop
    end
  end

  @doc """
  Forwards to the main module
  """
  def get_updated_reservation(reservation, attrs) do
    ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSync.get_updated_reservation(
      reservation,
      attrs
    )

    # {:ok, reservation}
  end
end
