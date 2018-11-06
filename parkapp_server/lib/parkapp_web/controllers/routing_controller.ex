defmodule ParkappWeb.RoutingController do
  @moduledoc """
    The RoutingController handles the routing related requests.
  """
  use ParkappWeb, :controller

  alias ParkappWeb.Utils
  alias ParkappWeb.ApiIntegration.Embers.Helpers

  # Add an error handler controller
  action_fallback(ParkappWeb.FallbackController)


  @doc """
    Returns the itinerary between the from and to geo_points.
  """
  def route(_conn, %{"from" => "null"}) do
    {:bad_request, "From cannot be null"}
  end

  def route(_conn, %{"to" => "null"}) do
    {:bad_request, "To cannot be null"}
  end

  def route(_conn, %{"mode" => "null"}) do
    {:bad_request, "Mode cannot be null"}
  end

  def route(_conn, %{"from" => from, "to" => to, "mode" => mode}) do
    module = Helpers.get_api_module()

    case module.get_route(
           from,
           to,
           mode
         ) do
      nil ->
        {:bad_request, "Something went wrong"}

      {:error, result} ->
        Logger.warn(Poison.encode!(result))
        {:bad_request, "Invalid parameters"}

      {:ok, result} ->
        result =
          Map.get(result, "plan", %{})
          |> Map.get("itineraries", [])
          |> List.first()
          |> get_route_legs()

        {:ok, %{itinerary: result}}
    end
  end

  def route(_conn, _params) do
    {:generic_unprocessable_entity, "Invalid parameters"}
  end

  defp get_route_legs(nil) do
    []
  end

  defp get_route_legs(itinerary) do
    Map.get(itinerary, "legs", [])
    |> Enum.map(fn leg ->
      route =
        Map.get(leg, "route", "")
        |> Polyline.decode()
        |> Enum.map(fn {long, lat} ->
          %{
            lat: format_geo_point_value(lat),
            long: format_geo_point_value(long)
          }
        end)

      Map.put(leg, "route", route)
    end)
  end

  defp format_geo_point_value(value) do
    Utils.parse_string_to_float("#{value}")
    |> Utils.format_float_decimal_places(5)
  end
end
