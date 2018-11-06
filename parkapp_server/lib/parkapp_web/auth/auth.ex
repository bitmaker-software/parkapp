defmodule ParkappWeb.Auth do
  @moduledoc """
  The Auth module contains the related methods to the middle layer between the Parkapp.Auth and the AuthenticationController.
  """
  alias __MODULE__.{
    Guardian,
    Secret
  }

  alias Parkapp.Auth.Devices

  @doc """
  Generates an encrypted secret for the given device.
  The unencrypted secret is stored in the database
  """
  @spec generate_encrypted_secret(Device) :: String | nil
  def generate_encrypted_secret(device) do
    with(
      secret <- Secret.generate_secret(),
      {:ok, device} <- Devices.update_device_secret(device, %{"secret" => secret}),
      false <- is_nil(device.key)
    ) do
      Secret.encrypt_client_secret(device.key, secret)
    else
      _ -> nil
    end
  end

  @doc """
  Generates a token for the given device.
  """
  @spec generate_token(Plug.Conn, Device, String) :: {Plug.Conn, String} | nil
  def generate_token(conn, device, secret) do
    with(
      false <- is_nil(device.secret),
      true <- device.secret == secret,
      {conn, jwt} <- Guardian.generate_auth_token(conn, device)
    ) do
      {conn, jwt}
    else
      _ -> nil
    end
  end

  @spec get_current_session_device(Plug.Conn) :: Device
  def get_current_session_device(conn) do
    Guardian.Plug.current_resource(conn)
  end

  @spec verify_token(String) :: {:ok, Device} | :error
  def verify_token(token) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        Guardian.resource_from_claims(claims)

      {:error, _reason} ->
        :error
    end
  end
end
