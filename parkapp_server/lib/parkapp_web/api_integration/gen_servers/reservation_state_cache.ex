defmodule ParkappWeb.ApiIntegration.GenServers.ReservationStateCache do
  @moduledoc """
    Encapsulates a cache for the gen server state.
    This allows for the recovery of state after a crash.
  """

  alias ParkappWeb.ApiIntegration.GenServers.ReservationState

  @ets_table_name :reservation_state_cache

  @doc """
    Creates the ets table
  """
  @spec init() :: Atom
  def init() do
    :ets.new(@ets_table_name, [:named_table, :set, :public])
  end

  @doc """
    Checks if table has been created
  """
  @spec exists?() :: Boolean
  def exists?() do
    :ets.whereis(@ets_table_name)
    |> case do
      :undefined ->
        false

      _else ->
        true
    end
  end

  @doc """
    Inserts state into ets table with key pid
  """
  @spec stash_state(Atom, ReservationState) :: true
  def stash_state(pid, %ReservationState{} = state) when is_atom(pid) do
    :ets.insert(@ets_table_name, {pid, state})
  end

  @doc """
    Looks up pid in ets table, returns the found state or the default state
  """
  @spec get_stash(Atom) :: ReservationState
  def get_stash(pid) when is_atom(pid) do
    :ets.lookup(@ets_table_name, pid)
    |> case do
      [{_pid, %ReservationState{} = state}] -> state
      [] -> %ReservationState{}
    end
  end

  @doc """
    Clears a stored stash with the given key
  """
  @spec clean_stash(Atom) :: true
  def clean_stash(pid) when is_atom(pid) do
    :ets.delete(@ets_table_name, pid)
  end

  @doc """
    Deletes the ets table
  """
  @spec terminate() :: true
  def terminate() do
    :ets.delete(@ets_table_name)
  end
end
