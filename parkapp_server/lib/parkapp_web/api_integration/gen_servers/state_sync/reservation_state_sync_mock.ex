defmodule ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSyncMock do
  @moduledoc """
    Handles the internal state sync with the external APIs
  """

  @behaviour ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSyncBehaviour

  @doc """
  Always returns :noop
  """
  def get_updated_reservation_status(_reservation) do
    :noop
  end

  @doc """
  Always returns the given reservation
  """
  def get_updated_reservation(reservation, _attrs) do
    {:ok, reservation}
  end
end
