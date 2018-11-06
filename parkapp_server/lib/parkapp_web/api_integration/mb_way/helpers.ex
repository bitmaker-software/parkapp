defmodule ParkappWeb.ApiIntegration.MBWay.Helpers do
  @moduledoc """
    Helpers that support the MBWay API integration
  """

  import ParkappWeb.ApiIntegration.Helpers
  require Logger

  @doc """
    Returns the correct module to use to call the MBway API
  """
  def get_api_module() do
    Application.get_env(:parkapp, :mb_way_api, [])
    |> Enum.into(%{})
    |> Map.get(:module)
  end

  @doc """
    Returns the configuration for correcly calling the MBway API
  """
  def get_config() do
    config =
      Application.get_env(:parkapp, :mb_way_api, [])
      |> Enum.into(%{})

    domain = Map.get(config, :domain, "")
    user_id = Map.get(config, :user_id, "")
    entity_id = Map.get(config, :entity_id, "")
    password = Map.get(config, :password, "")
    payment_brand = Map.get(config, :payment_brand, "")
    currency = Map.get(config, :currency, "")
    payment_type = Map.get(config, :payment_type, "")

    {domain, user_id, entity_id, password, payment_brand, currency, payment_type}
  end

  @doc """
    Generic handler for HTTP respose
  """
  def handle_http_response(response, default \\ nil) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, get_json(body, default)}

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        {:error, get_json(body, default)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        # this means the config values are incorrect
        Logger.error(status_code)
        default

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(reason)
        default
    end
  end

  @doc """
    Checks if the given value is nil or ""
  """
  defguard is_empty(value) when is_nil(value) or value == ""

  @doc """
    Decrypts the payload from MBWay webhook
  """
  @spec decrypt_hexadecimal_response(String, String, String) :: String | :error
  def decrypt_hexadecimal_response(http_body, auth_tag_from_http_header, iv_from_http_header)
      when is_empty(http_body) or is_empty(auth_tag_from_http_header) or
             is_empty(iv_from_http_header),
      do: :error

  def decrypt_hexadecimal_response(http_body, auth_tag_from_http_header, iv_from_http_header) do
    secret_from_config =
      Application.get_env(:parkapp, :mb_way_api, [])
      |> Enum.into(%{})
      |> Map.get(:decrypt_secret, "")
      |> Base.decode16!(case: :mixed)

    with(
      {:ok, iv_from_http_header} <- Base.decode16(iv_from_http_header, case: :mixed),
      {:ok, auth_tag_from_http_header} <- Base.decode16(auth_tag_from_http_header, case: :mixed),
      {:ok, http_body} <- Base.decode16(http_body, case: :mixed)
    ) do
      :crypto.block_decrypt(
        :aes_gcm,
        secret_from_config,
        iv_from_http_header,
        {"", http_body, auth_tag_from_http_header}
      )
    else
      _ ->
        :error
    end
  end
end
