defmodule ParkappWeb.ChangesetView do
  use ParkappWeb, :view

  require Logger

  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    Logger.error(Poison.encode!(%{error: translate_errors(changeset)}))
    %{error: translate_errors(changeset)}
  end

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `ParkappWeb.ErrorHelpers.translate_error/1` for more details.
  """
  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(
      changeset,
      &translate_error/1
    )
  end
end
