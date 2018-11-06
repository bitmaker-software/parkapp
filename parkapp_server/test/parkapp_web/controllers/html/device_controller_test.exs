defmodule ParkappWeb.HTML.DeviceControllerTest do
  use ParkappWeb.ConnCase

  alias Parkapp.DataCase

  describe "index" do
    @tag :with_auth
    test "lists all devices", %{conn: conn} do
      conn = get(conn, device_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Devices"
    end
  end

  describe "new device" do
    @tag :with_auth
    test "renders form", %{conn: conn} do
      conn = get(conn, device_path(conn, :new))
      assert html_response(conn, 200) =~ "New Device"
    end
  end

  describe "create device" do
    @tag :with_auth
    test "redirects to show when data is valid", %{conn: auth_conn} do
      conn =
        post(auth_conn, device_path(auth_conn, :create),
          device: %{device_id: Ecto.UUID.generate()}
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == device_path(conn, :show, id)

      conn = get(auth_conn, device_path(auth_conn, :show, id))
      assert html_response(conn, 200) =~ "Show Device"
    end

    @tag :with_auth
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, device_path(conn, :create), device: %{})
      assert html_response(conn, 200) =~ "New Device"
    end
  end

  describe "generate new device" do
    @tag :with_auth
    test "redirects to show when data is valid", %{conn: auth_conn} do
      conn = post(auth_conn, device_path(auth_conn, :generate_new))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == device_path(conn, :show, id)

      conn = get(auth_conn, device_path(auth_conn, :show, id))
      assert html_response(conn, 200) =~ "Show Device"
    end
  end

  describe "edit device" do
    setup [:create_device]

    @tag :with_auth
    test "renders form for editing chosen device", %{conn: conn, device: device} do
      conn = get(conn, device_path(conn, :edit, device))
      assert html_response(conn, 200) =~ "Edit Device"
    end
  end

  describe "update device" do
    setup [:create_device]

    @tag :with_auth
    test "redirects when data is valid", %{conn: auth_conn, device: device} do
      new_uuid = Ecto.UUID.generate()

      conn =
        put(auth_conn, device_path(auth_conn, :update, device), device: %{device_id: new_uuid})

      assert redirected_to(conn) == device_path(conn, :show, new_uuid)

      conn = get(auth_conn, device_path(auth_conn, :show, new_uuid))
      assert html_response(conn, 200) =~ new_uuid
    end

    @tag :with_auth
    test "renders errors when data is invalid", %{conn: conn, device: device} do
      conn = put(conn, device_path(conn, :update, device), device: %{device_id: ""})
      assert html_response(conn, 200) =~ "Edit Device"
    end
  end

  describe "unauthorize" do
    setup [:create_device]

    test "all device routes", %{conn: conn, device: device} do
      Enum.each(
        [
          get(conn, device_path(conn, :index)),
          get(conn, device_path(conn, :new)),
          post(conn, device_path(conn, :generate_new)),
          post(conn, device_path(conn, :create), device: %{device_id: Ecto.UUID.generate()}),
          get(conn, device_path(conn, :show, device)),
          get(conn, device_path(conn, :edit, device)),
          put(conn, device_path(conn, :update, device), device: %{device_id: Ecto.UUID.generate()})
        ],
        fn conn ->
          assert redirected_to(conn) == authentication_path(conn, :login)
        end
      )
    end
  end

  defp create_device(_) do
    device = DataCase.device_fixture()
    {:ok, device: device}
  end
end
