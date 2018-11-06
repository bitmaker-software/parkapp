defmodule ParkappWeb.HTML.HomeController do
  @moduledoc """
  """
  use ParkappWeb, :controller

  def current_version(conn, _params) do
    render(conn, "current_version.html", %{})
  end
end
