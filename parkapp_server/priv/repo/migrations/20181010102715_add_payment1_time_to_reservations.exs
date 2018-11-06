defmodule Parkapp.Repo.Migrations.AddPayment1TimeToReservations do
  use Ecto.Migration

  def change do
    alter(table(:reservations)) do
      add(:payment1_time, :utc_datetime) 
    end
  end
end
