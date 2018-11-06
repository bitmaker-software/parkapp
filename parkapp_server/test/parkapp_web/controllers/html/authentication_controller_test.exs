defmodule ParkappWeb.HTML.AuthenticationControllerTest do
  use ParkappWeb.ConnCase

  describe "AuthenticationController Happy Path" do
    test "GET /login", %{conn: conn} do
      conn =
        conn
        |> get(authentication_path(conn, :login))

      assert html_response(conn, 200) =~ "Login"
    end

    test "POST /login", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :process_login, %{login: %{secret: "bitmaker"}}))

      assert redirected_to(conn) == home_path(conn, :current_version)
      assert get_flash(conn, :info) == "Logged in"
    end
  end

  describe "AuthenticationController Fail Path" do
    test "POST /login with wrong secret", %{conn: conn} do
      conn =
        conn
        |> post(authentication_path(conn, :process_login, %{login: %{secret: ""}}))

      assert html_response(conn, 200) =~ "Login"
      assert get_flash(conn, :error) == "Wrong secret"
    end
  end
end
