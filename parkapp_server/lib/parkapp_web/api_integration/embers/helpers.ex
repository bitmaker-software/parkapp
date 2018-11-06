defmodule ParkappWeb.ApiIntegration.Embers.Helpers do
  @moduledoc """
    Helpers that support the Embers API integration
  """

  import ParkappWeb.ApiIntegration.Helpers
  require Logger

  @doc """
    Returns the module to use for the API calls
  """
  def get_api_module() do
    Application.get_env(:parkapp, :embers_api, [])
    |> Enum.into(%{})
    |> Map.get(:module)
  end

  @doc """
  Returns the configuration to call the correct API
  """
  def get_config(:routing) do
    config =
      Application.get_env(:parkapp, :embers_api, [])
      |> Enum.into(%{})

    domain = Map.get(config, :domain, "")

    public_transportation_agencies_time_zone =
      Map.get(config, :public_transportation_agencies_time_zone, "Etc/UTC")

    config = Map.get(config, :routing, %{})

    api_key = Map.get(config, :api_key, "")

    max_walk_distance = Map.get(config, :max_walk_distance, "")

    {domain, api_key, max_walk_distance, public_transportation_agencies_time_zone}
  end

  def get_config(:trindade_park) do
    config =
      Application.get_env(:parkapp, :embers_api, [])
      |> Enum.into(%{})

    domain = Map.get(config, :domain, "")

    public_transportation_agencies_time_zone =
      Map.get(config, :public_transportation_agencies_time_zone, "Etc/UTC")

    trindade_park_config =
      config
      |> Map.get(:trindade_park, %{})

    api_key =
      trindade_park_config
      |> Map.get(:api_key, "")

    park_time_available =
      trindade_park_config
      |> Map.get(:park_time_available, 1)

    {domain, api_key, public_transportation_agencies_time_zone, park_time_available}
  end

  def get_config(_id), do: :error

  @doc """
  Returns utc_now date and time with the format supported by the Embers's API
  """
  def now_date_time_tuple_with_format(timezone) do
    now = Timex.now(timezone)
    date = Timex.format!(now, "%Y-%m-%d", :strftime)
    time = Timex.format!(now, "%H:%M", :strftime)

    {date, time}
  end

  @doc """
    Given a datetime, a string representation of it is returned with the API's supported format
  """
  def format_date_time(datetime) do
    date = Timex.format!(datetime, "%Y-%m-%d", :strftime)
    time = Timex.format!(datetime, "%H:%M:%S", :strftime)

    "#{date}T#{time}"
  end

  @doc """
    Generic handler for HTTP requests
  """
  def handle_http_response(response, default \\ nil) do
    case response do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
      when status_code in [200, 204] ->
        {:ok, get_json(body, default)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
      when status_code in [400, 403] ->
        {:error, get_json(body, default)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.warn(status_code)
        default

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(reason)
        default
    end
  end

  @doc """
  Generic HTTP GET request for Embers's API
  """
  def get(url, api_key) do
    HTTPoison.get(
      url,
      "X-Gravitee-Api-Key": api_key
    )
  end

  @doc """
  Generic HTTP DELETE request for Embers's API
  """
  def delete(url, api_key) do
    HTTPoison.delete(
      url,
      "X-Gravitee-Api-Key": api_key
    )
  end

  @doc """
  Generic HTTP POST request for Embers's API
  """
  def post(url, api_key, data) do
    HTTPoison.post(
      url,
      Poison.encode!(data),
      "Content-Type": "application/json",
      "X-Gravitee-Api-Key": api_key,
      accept: "application/json"
    )
  end

  @doc """
  Generic HTTP PUT request for Embers's API
  """
  def put(url, api_key, data) do
    HTTPoison.put(
      url,
      Poison.encode!(data),
      "Content-Type": "application/json",
      "X-Gravitee-Api-Key": api_key,
      accept: "application/json"
    )
  end
end
