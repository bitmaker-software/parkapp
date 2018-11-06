defmodule ParkappWeb.Auth.Secret do
  @moduledoc """
  The Secret module contains the secret related methods.
  """

  alias ParkappWeb.Utils
  alias ParkappWeb.Auth.RSA.KeyLoader
  alias ParkappWeb.Auth.RSA.RSACrypto

  @secret_length 256
  @private_key_path "/priv/keys/private_test_key.key"

  def generate_secret() do
    Application.get_env(:parkapp, :secret_length, @secret_length)
    |> Utils.random_string()
  end

  def decrypt_client_secret(encrypted_secret) do
    File.cwd!()
    |> Path.join(Application.get_env(:parkapp, :private_key_path, @private_key_path))
    |> KeyLoader.load_private_key_from_file()
    |> RSACrypto.decrypt_message_private(encrypted_secret)
  end

  def encrypt_client_secret(device_public_key, secret) do
    KeyLoader.load_public_key(device_public_key)
    |> RSACrypto.encrypt_message_public(secret)
  end
end
