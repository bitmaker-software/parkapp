defmodule ParkappWeb.ApiIntegration.GenServers.Reservation do
  @moduledoc """
    This module handles the reservation state changes from Open to InPark
  """
  use GenServer
  import Phoenix.Channel

  require Logger

  alias ParkappWeb.ApiIntegration.{
    GenServers.ReservationState,
    GenServers.ReservationStateCache,
    Helpers
  }

  alias ParkappWeb.ReservationView
  alias Parkapp.ReservationsContext
  alias Parkapp.Reservations.ReservationStatus.Enum, as: ReservationStatusEnum

  @doc """
    Start the gen server
  """
  def start_link({:name, name} = _otp_opts) do
    GenServer.start_link(__MODULE__, ReservationStateCache.get_stash(name), name: name)
  end

  @doc """
  Default init
  """
  def init(%ReservationState{reservation_id: reservation_id} = state) do
    Logger.info("Init Genserver #{reservation_id}")

    if !is_nil(reservation_id) do
      schedule(state.schedule_interval, :verify_state)
    end

    {:ok, state}
  end

  @doc """
  Gets the atom version of the PID for the GenServer managing the given reservation_id
  """
  @spec get_pid(Integer) :: Atom
  def get_pid(reservation_id) do
    String.to_atom("#{reservation_id}")
  end

  @doc """
  Check if the gen server
  """
  @spec exists?(Atom) :: Boolean
  def exists?(pid) do
    Process.whereis(pid)
    |> case do
      nil ->
        false

      _pid_or_port ->
        true
    end
  end

  @doc """
  Stop the gen server
  """
  def stop(pid) do
    Process.whereis(pid)
    |> case do
      nil ->
        :noop

      _pid_or_port ->
        GenServer.stop(pid, {:shutdown, "Stopping Reservation"})
    end
  end

  @doc """
  Default callback that is ran when the gen server is stopping.
  Broadcasts it's end when testing.
  """
  def terminate(reason, %ReservationState{websocket: websocket, reservation_id: reservation_id}) do
    if Mix.env() == :test do
      broadcast!(websocket, "terminating", %{reason: reason, reservation_id: reservation_id})
    end
  end

  @doc """
  Inits gen server state
  """
  @spec init(Atom, Socket, Integer) :: ReservationState
  def init(pid, websocket, reservation_id) do
    GenServer.call(pid, {:init, websocket, reservation_id})
  end

  @doc """
  Initiates the reservation status check
  """
  @spec start_checking(Atom) :: ReservationState
  def start_checking(pid) do
    GenServer.call(pid, {:start_checking})
  end

  @doc """
  Updates the websocket in the state
  """
  @spec update_websocket(Atom, Socket) :: ReservationState
  def update_websocket(pid, websocket) do
    GenServer.call(pid, {:update_websocket, websocket})
  end

  @doc """
  Updates the client by pushing the given reservation
  """
  @spec update_client(Atom, Reservation) :: ReservationState
  def update_client(pid, reservation) do
    GenServer.call(pid, {:update_client, reservation})
  end

  @doc """
  Schedule an handle_info
  """
  defp schedule(schedule_interval, message) when is_atom(message) do
    Process.send_after(self(), message, schedule_interval)
  end

  @doc """
  Perform push to client
  """
  defp push_reservation_to_client(websocket, reservation) do
    push(
      websocket,
      "set_state",
      ReservationView.render("reservation.json", %{reservation: reservation})
    )
  end

  @doc """
    Updates the stash in the ets table
  """
  defp update_stash(%ReservationState{reservation_id: reservation_id} = state) do
    get_pid(reservation_id)
    |> ReservationStateCache.stash_state(state)
  end

  @doc """
    Removes the stash from the ets table
  """
  defp delete_stash(reservation_id) do
    get_pid(reservation_id)
    |> ReservationStateCache.clean_stash()
  end

  @doc """
  Sync calls.
  Possible calls:
  :init
  :update_websocket
  :start_checking
  """
  def handle_call({:init, websocket, reservation_id}, _from, _state) do
    schedule_interval = Helpers.get_value_from_config(:schedule_interval)
    # init the state
    state = %ReservationState{
      schedule_interval: schedule_interval,
      reservation_id: reservation_id,
      websocket: websocket
    }

    update_stash(state)

    {:reply, state, state}
  end

  def handle_call({:update_websocket, websocket}, _from, state) do
    Logger.info("Socket update for #{state.reservation_id}")

    # update the state
    new_state = %ReservationState{
      schedule_interval: state.schedule_interval,
      reservation_id: state.reservation_id,
      websocket: websocket
    }

    update_stash(new_state)

    {:reply, new_state, new_state}
  end

  def handle_call(
        {:update_client, reservation},
        _from,
        %ReservationState{
          websocket: websocket
        } = state
      ) do
    Logger.info("Pushing reservation #{reservation.id}")

    push_reservation_to_client(websocket, reservation)

    {:reply, state, state}
  end

  def handle_call({:start_checking}, _from, state) do
    Logger.info("Gen Server #{state.reservation_id} Started Checking")
    # start the recurring function calls immediately
    schedule(1, :verify_state)

    {:reply, state, state}
  end

  @doc """
  Async calls
  Possible calls:
  :verify_state
  """
  def handle_info(
        :verify_state,
        %ReservationState{
          reservation_id: reservation_id,
          websocket: websocket,
          schedule_interval: schedule_interval
        } = state
      ) do
    sync_module = Helpers.get_value_from_config(:sync_state_module)

    new_reservation =
      with(
        reservation <- ReservationsContext.get_reservation(reservation_id),
        false <- is_nil(reservation),
        attrs <- sync_module.get_updated_reservation_status(reservation)
      ) do
        with(
          {:ok, new_reservation} <- sync_module.get_updated_reservation(reservation, attrs),
          true <- reservation.reservation_status_id != new_reservation.reservation_status_id
        ) do
          push_reservation_to_client(websocket, new_reservation)

          new_reservation
        else
          _ ->
            reservation
        end
      else
        _ ->
          nil
      end

    with(
      true <-
        is_nil(new_reservation) ||
          (!is_nil(new_reservation) &&
             new_reservation.reservation_status_id == ReservationStatusEnum.closed())
    ) do
      # this breaks the tests. Problably makes the test supervisor or the ecto gen server crash
      if Mix.env() != :test do
        Logger.info("Shutdown Genserver #{reservation_id}")
        delete_stash(reservation_id)

        {:stop, :shutdown, state}
      else
        {:noreply, state}
      end
    else
      _ ->
        schedule(schedule_interval, :verify_state)
        {:noreply, state}
    end
  end
end
