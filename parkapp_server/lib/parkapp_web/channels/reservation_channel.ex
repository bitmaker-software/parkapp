defmodule ParkappWeb.ReservationChannel do
  use Phoenix.Channel

  alias ParkappWeb.Auth

  alias ParkappWeb.ApiIntegration.GenServers.{
    Reservation,
    ReservationState
  }

  alias ParkappWeb.ReservationView
  alias Parkapp.ReservationsContext

  @doc """
    Joins the agent on a reservation channel.
  """
  def join("reservation:" <> _username, %{"token" => token}, socket) do
    case Auth.verify_token(token) do
      :error ->
        {:error, %{error: "unauthorized"}}

      {:ok, _device} ->
        {:ok, %{message: "joined"}, socket}
    end
  end

  @doc """
  Entry point to every event handled by the channel
  """
  def handle_in(event, %{"token" => token} = payload, websocket) do
    case Auth.verify_token(token) do
      :error ->
        {:reply, {:error, %{error: "unauthorized"}}, websocket}

      {:ok, device} ->
        handle_event(event, %{device: device, payload: payload}, websocket)
    end
  end

  @doc """
    Starts a Gen Server for the given current reservation
    If the Gen Server already exists, it updates it's websocket
  """
  @spec handle_event(String, Map, Socket) :: {:reply, {:ok, Map} | {:error, Map}, Socket}
  defp handle_event("START", %{device: %{device_id: device_id}}, websocket) do
    with(
      reservation <- ReservationsContext.get_current_reservation(device_id),
      false <- is_nil(reservation),
      gen_server_id <- Reservation.get_pid(reservation.id)
    ) do
      case Reservation.exists?(gen_server_id) do
        true ->
          Reservation.update_websocket(gen_server_id, websocket)
          Reservation.update_client(gen_server_id, reservation)
          {:reply, {:ok, %{message: "success"}}, websocket}

        false ->
          start_gen_server(gen_server_id)

          case Reservation.init(gen_server_id, websocket, reservation.id) do
            nil ->
              {:reply, {:error, %{error: "gen_server_init_fail"}}, websocket}

            %ReservationState{} = _state ->
              Reservation.start_checking(gen_server_id)
              {:reply, {:ok, %{message: "success"}}, websocket}
          end
      end
    else
      _ ->
        push(websocket, "set_state", ReservationView.render("reservation_not_found.json", %{}))

        {:reply, {:ok, %{message: "success"}}, websocket}
    end
  end

  defp start_gen_server(gen_server_id) do
    case Supervisor.start_child(Parkapp.Supervisor, %{
           id: gen_server_id,
           start: {Reservation, :start_link, [name: gen_server_id]},
           restart: :transient
         }) do
      {:error, :already_present} ->
        Supervisor.restart_child(Parkapp.Supervisor, gen_server_id)
        |> IO.inspect(label: "start_gen_server/1 - restarted")

      other ->
        other
        |> IO.inspect(label: "start_gen_server/1 - result")
    end
  end
end
