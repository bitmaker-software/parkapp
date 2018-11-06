defmodule ParkappWeb.ApiIntegration.GenServers.StateSync.PresenceStatus do
  @moduledoc """
    Defines the precense status constants to use
  """

  defmacro __using__(_opts) do
    quote do
      @inpark 3
      @closed 1
      @undefined 0
    end
  end
end
