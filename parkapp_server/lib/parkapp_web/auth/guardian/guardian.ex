defmodule ParkappWeb.Auth.Guardian do
  use Guardian, otp_app: :parkapp

  alias Parkapp.Auth.Devices

  def subject_for_token(resource, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = to_string(resource.device_id)
    {:ok, sub}
  end

  # def subject_for_token(_, _) do
  #   {:error, :reason_for_error}
  # end

  def resource_from_claims(claims) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In `above subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    device_id = claims["sub"]
    resource = Devices.get_device!(device_id)
    {:ok, resource}
  end

  def generate_auth_token(conn, device) do
    # Encode a JWT token and update the conn
    {:ok, jwt, _} = encode_and_sign(device, %{}, token_type: "access")
    auth_conn = __MODULE__.Plug.sign_in(conn, device)
    # jwt = Guardian.Plug.current_token(auth_conn)

    {auth_conn, jwt}
  end

  def generate_mock_auth_token(conn) do
    mock_device = %{device_id: "device_id"}
    {:ok, _jwt, _} = encode_and_sign(mock_device, %{}, token_type: "access")
    __MODULE__.Plug.sign_in(conn, mock_device)
  end

  # def resource_from_claims(_claims) do
  #   {:error, :reason_for_error}
  # end
end
