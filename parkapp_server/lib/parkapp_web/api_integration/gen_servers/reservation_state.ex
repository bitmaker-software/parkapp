defmodule ParkappWeb.ApiIntegration.GenServers.ReservationState do
  defstruct reservation_id: nil,
            websocket: nil,
            schedule_interval: 1000
end
