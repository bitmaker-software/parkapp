defmodule ParkappWeb.Auth.Guardian.ErrorHandler do
  import Plug.Conn

  @doc """
    Handler when a connection is invalid (e.g. token is invalid).
  """
  def auth_error(conn, {type, _reason}, _opts) do
    body = Poison.encode!(%{error: to_string(type)})
    send_resp(conn, :unauthorized, body)
  end
end

defmodule ParkappWeb.Auth.Guardian.BrowserErrorHandler do
  use ParkappWeb, :controller

  def auth_error(conn, {_type, _reason}, _opts) do
    conn = ParkappWeb.Auth.Guardian.Plug.sign_out(conn)

    redirect(conn, to: authentication_path(conn, :login))
  end
end
