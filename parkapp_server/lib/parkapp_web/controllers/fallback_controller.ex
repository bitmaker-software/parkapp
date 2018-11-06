defmodule ParkappWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ParkappWeb, :controller

  def call(conn, {:ok, response_map}) do
    conn
    |> response(:ok, response_map)
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(
      ParkappWeb.ChangesetView,
      "error.json",
      changeset: changeset
    )
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(
      ParkappWeb.ErrorView,
      "error.json",
      message: "Not found"
    )
  end

  def call(conn, :invalid_file_path) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(
      ParkappWeb.ErrorView,
      "error.json",
      message: "Invalid file path"
    )
  end

  def call(conn, {:generic_unprocessable_entity, message}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(
      ParkappWeb.ErrorView,
      "error.json",
      message: message
    )
  end

  def call(conn, {status_code, message}) do
    conn
    |> put_status(status_code)
    |> render(
      ParkappWeb.ErrorView,
      "error.json",
      message: message
    )
  end

  def call(conn, _xpto) do
    conn
    |> response(:bad_request, %{})
  end

  defp response(conn, status_code, map) do
    conn
    |> put_status(status_code)
    |> json(map)
  end
end
