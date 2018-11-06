defmodule ParkappWeb.HTML.AuthenticationController do
  @moduledoc """
  The HTML AuthenticationController handles the simple web login
  """
  use ParkappWeb, :controller
  alias ParkappWeb.Auth

  def login(conn, _) do
    render(conn, "login.html")
  end

  def process_login(conn, %{"login" => %{"secret" => secret}}) do
    cond do
      secret == "bitmaker" ->
        conn = Auth.Guardian.generate_mock_auth_token(conn)

        put_flash(conn, :info, "Logged in")
        |> redirect(to: home_path(conn, :current_version))

      true ->
        put_flash(conn, :error, "Wrong secret")
        |> render("login.html")
    end
  end
end
