defmodule ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSyncBehaviour do
  @moduledoc """
    Defines the behaviour of a reservation state sync
  """

  @callback get_updated_reservation_status(Reservation) :: :noop | Map
  @callback get_updated_reservation(Reservation, :noop | Map) :: {:ok, Reservation}
end
