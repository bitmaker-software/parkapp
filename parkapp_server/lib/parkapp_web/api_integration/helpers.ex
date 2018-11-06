defmodule ParkappWeb.ApiIntegration.Helpers do
  @moduledoc """
    Helpers that support the API integrations
  """

  @doc """
    Decodes the body from json. Returns default if something goes wrong
  """
  @spec get_json(String, Any) :: Map | Any
  def get_json(body, default \\ nil) do
    with({:ok, result} <- Poison.decode(body)) do
      result
    else
      _ -> default
    end
  end

  @doc """
  Helper to get the time limits from the config
  """
  @spec get_value_from_config(Atom) :: Term
  def get_value_from_config(term) when is_atom(term) do
    Application.get_env(:parkapp, :reservations_gen_server, [])
    |> Enum.into(%{})
    |> Map.get(term)
  end
end
