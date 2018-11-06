defmodule ParkappWeb.HTML.MockReservationView do
  use ParkappWeb, :view
  alias Parkapp.ReservationsContext
  alias Parkapp.Auth.Devices

  def get_reservation_type_options() do
    ReservationsContext.list_reservation_types()
    |> Enum.map(fn type -> {type.name, type.id} end)
  end

  def get_device_options() do
    Devices.list_devices()
    |> Enum.map(fn device -> {device.device_id, device.device_id} end)
  end
end
