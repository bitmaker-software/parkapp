defmodule Parkapp.Repo.Migrations.AddCancelFieldsToReservations do
  use Ecto.Migration

  def change do
    alter(table(:reservations)) do
      add(:cancelled, :boolean, default: false)
      add(:cancelled_at, :utc_datetime)
    end
  end
end
