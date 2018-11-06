defmodule Parkapp.Repo.Migrations.CreateExternalPaymentLogs do
  use Ecto.Migration

  def change do
    create table(:external_payment_logs) do
      add :received_at, :utc_datetime
      add :params, :string
      add :reservation_id, references(:reservations, on_delete: :nothing)

      timestamps()
    end

    create index(:external_payment_logs, [:reservation_id])
  end
end
