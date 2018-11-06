defmodule ParkappWeb.Auth.RSA.KeyLoader do
  @moduledoc """
  The RSA.KeyLoader module is responsible for loading an encoded key into a key data structure which will be used in encryption/decryption
  """
  def load_public_key(public_key_string) do
    public_key_header = "-----BEGIN RSA PUBLIC KEY-----"
    public_key_footer = "-----END RSA PUBLIC KEY-----"

    client_public_key_encoded =
      Enum.join([public_key_header, public_key_string, public_key_footer], "\n")

    client_public_key_encoded |> ExPublicKey.loads!()
  end

  def load_private_key(private_key_string) do
    private_key_header = "-----BEGIN RSA PRIVATE KEY-----"
    private_key_footer = "-----END RSA PRIVATE KEY-----"

    client_private_key_encoded =
      Enum.join([private_key_header, private_key_string, private_key_footer], "\n")

    client_private_key_encoded |> ExPublicKey.loads!()
  end

  def load_public_key_from_file(public_key_file_path) do
    {:ok, public_key_string} = File.read(public_key_file_path)
    public_key_string |> ExPublicKey.loads!()
  end

  def load_private_key_from_file(private_key_file_path) do
    {:ok, private_key_string} = File.read(private_key_file_path)
    private_key_string |> ExPublicKey.loads!()
  end
end
