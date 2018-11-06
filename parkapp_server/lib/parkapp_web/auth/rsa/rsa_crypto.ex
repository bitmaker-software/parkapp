defmodule ParkappWeb.Auth.RSA.RSACrypto do
  @moduledoc """
  When decrypting, if the message was a string, but a binary is returned
  then you are passing the wrong key to the function
  """

  def encrypt_message_public(public_key, message_text) do
    {:ok, public_seq} = ExPublicKey.RSAPublicKey.as_sequence(public_key)
    {:RSAPublicKey, modulus, exponent} = public_seq
    padding = :proplists.get_value(:rsa_pad, [], :rsa_no_padding)
    encrypted_bytes = :crypto.public_encrypt(:rsa, message_text, [exponent, modulus], padding)
    encrypted_string = Base.encode64(encrypted_bytes)
    encrypted_string
  end

  def encrypt_message_private(private_key, message_text) do
    {:ok, private_seq} = ExPublicKey.RSAPrivateKey.as_sequence(private_key)
    padding = :proplists.get_value(:rsa_pad, [], :rsa_no_padding)

    encrypted_bytes =
      :crypto.private_encrypt(:rsa, message_text, format_rsa_private_key(private_seq), padding)

    encrypted_string = Base.encode64(encrypted_bytes)
    encrypted_string
  end

  def decrypt_message_private(private_key, encrypted_string) do
    {:ok, encrypted_bytes} = Base.decode64(encrypted_string, ignore: :whitespace)
    {:ok, private_seq} = ExPublicKey.RSAPrivateKey.as_sequence(private_key)
    padding = :proplists.get_value(:rsa_pad, [], :rsa_no_padding)
    :crypto.private_decrypt(:rsa, encrypted_bytes, format_rsa_private_key(private_seq), padding)
  end

  def decrypt_message_public(public_key, encrypted_string) do
    {:ok, encrypted_bytes} = Base.decode64(encrypted_string, ignore: :whitespace)
    {:ok, public_seq} = ExPublicKey.RSAPublicKey.as_sequence(public_key)
    padding = :proplists.get_value(:rsa_pad, [], :rsa_no_padding)
    :crypto.public_decrypt(:rsa, encrypted_bytes, format_rsa_public_key(public_seq), padding)
  end

  defp format_rsa_private_key(
         {:RSAPrivateKey, :"two-prime", modulus, publicExponent, privateExponent, prime1, prime2,
          exponent1, exponent2, coefficient, :asn1_NOVALUE}
       )
       when is_integer(modulus) and is_integer(publicExponent) and is_integer(privateExponent) and
              is_integer(prime1) and is_integer(prime2) and is_integer(exponent1) and
              is_integer(exponent2) and is_integer(coefficient) do
    [publicExponent, modulus, privateExponent, prime1, prime2, exponent1, exponent2, coefficient]
  end

  defp format_rsa_public_key({:RSAPublicKey, modulus, publicExponent})
       when is_integer(modulus) and is_integer(publicExponent) do
    [publicExponent, modulus]
  end
end
