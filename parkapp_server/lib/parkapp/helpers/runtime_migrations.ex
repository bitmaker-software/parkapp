defmodule Parkapp.Helpers.RuntimeMigrations do
  @moduledoc """
   Since mix tasks are not available in production, this strategy let's us
   have a server that can be called to run the migrations we might have.
  """
  require Logger
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [:ok], name: __MODULE__)
  end

  def init(state) do
    send(self(), :work)
    {:ok, state}
  end

  def handle_info(:work, state) do
    Logger.info("Running database migrations...")
    {:ok, _} = Application.ensure_all_started(:parkapp)
    path = Application.app_dir(:parkapp, "priv/repo/migrations")
    Ecto.Migrator.run(Parkapp.Repo, path, :up, all: true)
    {:stop, :normal, state}
  end
end
