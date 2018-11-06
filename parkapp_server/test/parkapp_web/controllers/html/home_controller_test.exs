defmodule ParkappWeb.HTML.HomeControllerTest do
  use ParkappWeb.ConnCase

  describe "current_version" do
    test "displays the home page", %{conn: conn} do
      conn = get conn, home_path(conn, :current_version)
      assert html_response(conn, 200) =~ "Devices"
      assert html_response(conn, 200) =~ "Reservations"
      assert html_response(conn, 200) =~ "Version 2"
    end
  end
end
