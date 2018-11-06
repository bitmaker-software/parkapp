defmodule Parkapp.Repo.Migrations.CreateReservations do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add :barcode, :string
      add :locator, :string
      add :context_token, :string
      add :amount, :string
      add :parking_start_time, :utc_datetime
      add :reservation_type_id, references(:reservation_types, on_delete: :nothing)
      add :reservation_status_id, references(:reservation_status, on_delete: :nothing)
      add :device_id, references(:devices, column: :device_id, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index(:reservations, [:reservation_type_id])
    create index(:reservations, [:reservation_status_id])
    create index(:reservations, [:device_id])
  end
end
