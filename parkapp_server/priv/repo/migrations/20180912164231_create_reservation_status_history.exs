defmodule Parkapp.Repo.Migrations.CreateRevervationStatusHistory do
  use Ecto.Migration

  def change do
    create table(:reservation_status_history) do
      add :transitioned_at, :utc_datetime
      add :active, :boolean
      add :reservation_id, references(:reservations, on_delete: :nothing)
      add :previous_reservation_status_id, references(:reservation_status, on_delete: :nothing)
      add :next_reservation_status_id, references(:reservation_status, on_delete: :nothing)

      timestamps()
    end

    create index(:reservation_status_history, [:reservation_id])
    create index(:reservation_status_history, [:previous_reservation_status_id])
    create index(:reservation_status_history, [:next_reservation_status_id])
  end
end
