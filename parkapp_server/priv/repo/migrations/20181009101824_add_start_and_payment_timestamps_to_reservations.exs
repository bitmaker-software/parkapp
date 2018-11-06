defmodule Parkapp.Repo.Migrations.AddStartAndPaymentTimestampsToReservations do
  use Ecto.Migration

  def change do
    alter(table(:reservations)) do
      add(:reservation_start_time, :utc_datetime)
      add(:parking_payment_time, :utc_datetime) 
    end
  end
end
