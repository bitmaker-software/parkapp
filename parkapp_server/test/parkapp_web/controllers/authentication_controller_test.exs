defmodule ParkappWeb.AuthenticationControllerTest do
  use ParkappWeb.ConnCase

  alias Parkapp.DataCase
  alias Parkapp.Auth.Devices
  alias Parkapp.Auth.Device
  alias ParkappWeb.Auth.Secret

  @moduletag :authentication_controller
  @public_key "MIIBCgKCAQEAjMeo71xLBPFZOWXbZ8rUbDjJzC/p6gk9JLR4RjqJEb9dnSm+qAbA8fG4SKguHJgs5BxJEMJmm7kG1C7GgTPlvFQdhdNRjw23aC34CTEaOuDznuH6y8fjqwrA6gu7ECg/gtACc+R87ArS/mn5w9aeLQcXBKzr3Gi8Yc1Ws9eaa3ukNSVC+GV9SfMWhS9JeiEUc00VbH3UgPFogHOya7PF2ddUckYN4pgxnZ0X39Prx5s/X1oA9lSolVbGxnbQfk4NPgEoKNLj90vQknJN7oPd50DcH3tlSKaOBu2lK1fcJs6Q7cTSukT/kzZxI8uojPpgjaE7fsZwvAsis0ScCabsxQIDAQAB"
  @device_id Ecto.UUID.generate()
  @other_device_id Ecto.UUID.generate()

  @encrypted_secret "SvYl1oOnKCWq7Z463QdEM/7VvEGwzyajve5AT2RXuekIiWTssT5ZJd3vdYMBK3D7kZUFkDA8fAo3s8+flFFoi6sugSsu9x04cmEA3godnU/LQOv77ZzxZwPyJPHcjJqM/H2PZI2dgTIsMclFJk/D6QMKK2ehXsil6VTW9wus/7eSGSthCCAb+X5gt8N0iaw3HyUcfJA3UW/lcvV/tX8FQAPrU91T+xOudDwHwNgrRXXnHlifhhjgzSJitmBswQ3k3jGf5RWgV0vOecuY7yumY0sTE0TXmWK9L7igIr4ZHTI1I6xuk5tCtW8tGGyW6KHdCzJAvdDRLg6gq1PgGUP7SQ=="

  @attrs %{device_id: @device_id, key: @public_key}

  describe "AuthenticationController Happy Path" do
    test "POST /register", %{conn: conn} do
      conn =
        conn
        |> post(
          authentication_path(conn, :register, device_id: @device_id, public_key: @public_key)
        )

      assert(conn.resp_body == "{}")
      assert(conn.status == 200)
      assert_device(@device_id, @public_key)
    end

    test "POST /register when device_id already exists", %{conn: conn} do
      Devices.create_device(@attrs)

      conn =
        conn
        |> post(
          authentication_path(conn, :register, device_id: @device_id, public_key: @public_key)
        )

      assert(conn.resp_body == "{\"error\":\"Device is already registered\"}")
      assert(conn.status == 400)
      assert_device(@device_id, @public_key)
    end

    test "POST /register when device_id already exists but with a new public key", %{conn: conn} do
      {:ok, device} = Devices.create_device(@attrs)

      conn =
        conn
        |> post(
          authentication_path(conn, :register,
            device_id: device.device_id,
            public_key: "new public key"
          )
        )

      assert(conn.resp_body == "{\"error\":\"Device is already registered\"}")
      assert(conn.status == 400)
      assert_device(device.device_id, device.key)
    end

    test "POST /authenticate_phase1", %{conn: conn} do
      Devices.create_device(@attrs)

      conn =
        conn
        |> post(authentication_path(conn, :authenticate_phase1, device_id: @device_id))

      assert(conn.status == 200)
      assert(String.contains?(conn.resp_body, "{\"secret\":"))
      encrypted_secret = get_from_resp_body(conn, "secret")
      assert_device(@attrs.device_id, @attrs.key, encrypted_secret)
    end

    test "POST /authenticate_phase2", %{conn: conn} do
      device = DataCase.device_fixture()

      conn = authenticate_phase2(device.device_id, conn)

      assert(conn.status == 200)
      assert(String.contains?(conn.resp_body, "\"token\""))
    end

    test "POST /logout", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> post(authentication_path(conn, :logout))

      assert(conn.status == 204)
      assert(conn.resp_body == "{}")

      attrs = DataCase.get_basic_device_attrs()

      conn =
        conn
        |> get(authentication_path(conn, :verify_token, device_id: attrs.device_id))

      assert(conn.resp_body == get_unauthorized_message())
      assert(conn.status == 401)
    end

    test "GET /verify_token", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      attrs = DataCase.get_basic_device_attrs()

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(authentication_path(conn, :verify_token, device_id: attrs.device_id))

      assert(conn.status == 200)
      assert(conn.resp_body == "{}")
    end
  end

  describe "AuthenticationController Fail Path with null input" do
    test "POST /register with device_id null", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :register, device_id: "null", public_key: @public_key))

      assert(conn.resp_body == "{\"error\":\"Device Id cannot be null\"}")
      assert(conn.status == 400)
    end

    test "POST /register with public_key null", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :register, device_id: @device_id, public_key: "null"))

      assert(conn.resp_body == "{\"error\":\"Device Public Key cannot be null\"}")
      assert(conn.status == 400)
    end

    test "POST /authenticate_phase1 with device_id null", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :authenticate_phase1, device_id: "null"))

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Device Id cannot be null\"}")
    end

    test "POST /authenticate_phase2 with device_id null", %{conn: conn} do
      conn =
        conn
        |> post(
          authentication_path(conn, :authenticate_phase2,
            device_id: "null",
            encrypted_secret: @encrypted_secret
          )
        )

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Device Id cannot be null\"}")
    end

    test "POST /authenticate_phase2 with encrypted_secret null", %{conn: conn} do
      conn =
        conn
        |> post(
          authentication_path(conn, :authenticate_phase2,
            device_id: @device_id,
            encrypted_secret: "null"
          )
        )

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Encrypted Secret cannot be null\"}")
    end

    test "GET /verify_token with device_id null", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(authentication_path(conn, :verify_token, device_id: "null"))

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Device Id cannot be null\"}")
    end
  end

  describe "AuthenticationController Fail Path" do
    test "POST /register with empty public_key", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :register, device_id: @device_id, public_key: ""))

      assert(conn.resp_body == "{\"error\":{\"key\":[\"can't be blank\"]}}")
      assert(conn.status == 422)
    end

    test "POST /register with no arguments", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :register))

      assert(conn.resp_body == "{\"error\":\"Invalid parameters\"}")
      assert(conn.status == 422)
    end

    test "POST /authenticate_phase1 with non existing device_id", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :authenticate_phase1, device_id: @other_device_id))

      assert(conn.status == 404)
      assert(conn.resp_body == "{\"error\":\"Could not find Device\"}")
      assert is_nil(Devices.get_device(@other_device_id))
    end

    test "PUT /authenticate_phase1 with no arguments", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :authenticate_phase1))

      assert(conn.resp_body == "{\"error\":\"Invalid parameters\"}")
      assert(conn.status == 422)
    end

    test "POST /authenticate_phase2 with non existing device_id", %{conn: conn} do
      conn =
        conn
        |> post(
          authentication_path(conn, :authenticate_phase2,
            device_id: @other_device_id,
            encrypted_secret: @encrypted_secret
          )
        )

      assert(conn.status == 404)
      assert(conn.resp_body == "{\"error\":\"Could not find Device\"}")
      assert is_nil(Devices.get_device(@other_device_id))
    end

    test "POST /authenticate_phase2 with empty encrypted_secret", %{conn: conn} do
      {:ok, device} = Devices.create_device(@attrs)

      conn =
        conn
        |> post(
          authentication_path(conn, :authenticate_phase2,
            device_id: @device_id,
            encrypted_secret: ""
          )
        )

      assert(conn.status == 500)
      assert(conn.resp_body == "{\"error\":\"Could not generate Encrypted Token\"}")
      assert_device(device.device_id, device.key)
      assert is_nil(device.secret)
    end

    test "PUT /authenticate_phase2 with no arguments", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :authenticate_phase2))

      assert(conn.resp_body == "{\"error\":\"Invalid parameters\"}")
      assert(conn.status == 422)
    end

    test "POST /logout", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> post(authentication_path(conn, :logout))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end

    test "GET /verify_token with no token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(authentication_path(conn, :verify_token, device_id: "device_id"))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end
  end

  defp assert_device(device_id, public_key) do
    assert %Device{} = device = Devices.get_device!(device_id)
    assert device.device_id == device_id
    assert device.key == public_key
  end

  defp assert_device(device_id, public_key, encrypted_secret) do
    assert %Device{} = device = Devices.get_device!(device_id)
    assert device.device_id == device_id
    assert device.key == public_key
    assert Secret.encrypt_client_secret(device.key, device.secret) == encrypted_secret
  end
end
