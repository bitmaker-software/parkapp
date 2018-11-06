defmodule ParkappWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import ParkappWeb.Router.Helpers
      import ParkappWeb.ConnCase

      # The default endpoint for testing
      @endpoint ParkappWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Parkapp.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Parkapp.Repo, {:shared, self()})
    end

    if tags[:with_auth] do
      {:ok, %{conn: build_mock_auth_conn()}}
    else
      {:ok, %{conn: Phoenix.ConnTest.build_conn()}}
    end
  end

  alias Parkapp.DataCase
  # Import conveniences for testing with connections
  use Phoenix.ConnTest
  import ParkappWeb.Router.Helpers

  # The default endpoint for testing
  @endpoint ParkappWeb.Endpoint

  def build_mock_auth_conn() do
    build_conn()
    |> ParkappWeb.Auth.Guardian.generate_mock_auth_token()
  end

  def get_unauthorized_message, do: "{\"error\":\"unauthenticated\"}"

  def get_jwt_token() do
    build_conn()
    |> get_jwt_token()
  end

  def get_jwt_token(conn) do
    device = DataCase.device_fixture()

    jwt =
      authenticate_phase2(device.device_id, conn)
      |> get_from_resp_body("token")

    {jwt, device.device_id}
  end

  def get_jwt_token_2(conn) do
    device_id = Ecto.UUID.generate()

    device =
      DataCase.device_fixture(%{
        device_id: device_id
      })

    jwt =
      authenticate_phase2(device.device_id, conn)
      |> get_from_resp_body("token")

    {jwt, device.device_id}
  end

  def authenticate_phase2(device_id, conn) do
    conn
    |> post(
      authentication_path(conn, :authenticate_phase2,
        device_id: device_id,
        encrypted_secret: DataCase.get_encrypted_secret()
      )
    )
  end

  def get_from_resp_body(conn, key) do
    conn
    |> Map.get(:resp_body, "")
    |> Poison.decode!()
    |> Map.get(key, "")
  end

  def get_webhook_mock(http_body) do
    iv = "000000000000000000000000"

    iv_from_http_header = iv |> Base.decode16!(case: :mixed)

    secret_from_config =
      Application.get_env(:parkapp, :mb_way_api, [])
      |> Enum.into(%{})
      |> Map.get(:decrypt_secret, "")
      |> Base.decode16!(case: :mixed)

    {http_body_encrypted, auth_tag_from_http_header} =
      :crypto.block_encrypt(
        :aes_gcm,
        secret_from_config,
        iv_from_http_header,
        {"", http_body}
      )

    http_body_encrypted =
      http_body_encrypted
      |> Base.encode16()

    auth_tag_from_http_header =
      auth_tag_from_http_header
      |> Base.encode16()

    {http_body_encrypted, iv, auth_tag_from_http_header}
  end
end
