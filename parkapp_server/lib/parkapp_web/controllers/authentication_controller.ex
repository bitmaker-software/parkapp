defmodule ParkappWeb.AuthenticationController do
  @moduledoc """
  The AuthenticationController module takes care of the handshake process between the server and the mobile-client.

  This process is done in 2 consecutive steps: **registration** and **authentication**.

  The **registration** process envolves the mobile-client sending his **device id** and his **public key** to the server, which will be stored in the database.

  The **authentication** process is a challenge-response process, and has 2 phases.
  In the first phase, the mobile-client tells the server he wants to authenticate, and the server answers with a secret (a random string) encrypted with the
  client's public key. The client decrypts the secret.
  In the second phase, the client encrypts the secret again, but with the server public key, and sends it to the server. The server then decrypts this secret,
  and if it matches the secret generated in the first phase, the server sends a token to the client, which he will use in all other requests to prove that he
  can access the server's endpoints.
  """
  use ParkappWeb, :controller
  alias Parkapp.Auth.Devices
  alias ParkappWeb.Auth.Secret
  alias ParkappWeb.Auth

  # Add an error handler controller
  action_fallback(ParkappWeb.FallbackController)

  @doc """
   Registers a new device

   If the device already exists just returns :ok
  """
  def register(_conn, %{"device_id" => "null"}),
    do: {:bad_request, "Device Id cannot be null"}

  def register(_conn, %{"public_key" => "null"}),
    do: {:bad_request, "Device Public Key cannot be null"}

  def register(_conn, %{"device_id" => device_id, "public_key" => public_key}) do
    case Devices.get_device(device_id) do
      nil ->
        with({:ok, _} <- Devices.create_device(%{device_id: device_id, key: public_key})) do
          {:ok, %{}}
        end

      _device ->
        {:bad_request, "Device is already registered"}
    end
  end

  def register(_conn, _), do: {:generic_unprocessable_entity, "Invalid parameters"}

  @doc """
    First authentication phase. Associates an encrypted secret with the given device
  """
  def authenticate_phase1(_conn, %{"device_id" => "null"}),
    do: {:bad_request, "Device Id cannot be null"}

  def authenticate_phase1(_conn, %{"device_id" => device_id}) do
    case Devices.get_device(device_id) do
      nil ->
        {:not_found, "Could not find Device"}

      device ->
        case Auth.generate_encrypted_secret(device) do
          nil ->
            {:internal_server_error, "Could not generate Encrypted Secret"}

          encrypted_secret ->
            {:ok, %{secret: encrypted_secret}}
        end
    end
  end

  def authenticate_phase1(_conn, _), do: {:generic_unprocessable_entity, "Invalid parameters"}

  @doc """
   Second authentication phase. Generates a JWT token for the given device.
  """
  def authenticate_phase2(_conn, %{"device_id" => "null"}),
    do: {:bad_request, "Device Id cannot be null"}

  def authenticate_phase2(_conn, %{"encrypted_secret" => "null"}),
    do: {:bad_request, "Encrypted Secret cannot be null"}

  def authenticate_phase2(conn, %{
        "device_id" => device_id,
        "encrypted_secret" => encrypted_secret
      }) do
    secret = Secret.decrypt_client_secret(encrypted_secret)

    case Devices.get_device(device_id) do
      nil ->
        {:not_found, "Could not find Device"}

      device ->
        case Auth.generate_token(conn, device, secret) do
          nil ->
            {:internal_server_error, "Could not generate Encrypted Token"}

          {auth_conn, jwt} ->
            auth_conn
            |> put_resp_header("authorization", "bearer #{jwt}")
            |> json(%{token: jwt})
        end
    end
  end

  def authenticate_phase2(_conn, _), do: {:generic_unprocessable_entity, "Invalid parameters"}

  #
  # For testing purposes only...
  #

  def logout(conn, _) do
    conn
    |> ParkappWeb.Auth.Guardian.Plug.sign_out()
    |> put_status(204)
    |> json(%{})
  end

  #
  # END For testing purposes only...
  #

  @doc """
    Checks if the connection has a legit token associated with it.
  """
  def verify_token(_conn, %{"device_id" => "null"}),
    do: {:bad_request, "Device Id cannot be null"}

  def verify_token(conn, %{"device_id" => device_id}) do
    device = Auth.get_current_session_device(conn)

    cond do
      device.device_id == device_id ->
        {:ok, %{}}

      true ->
        {:unauthorized, "Invalid token"}
    end
  end

  def verify_token(_conn, _), do: {:generic_unprocessable_entity, "Invalid parameters"}
end
