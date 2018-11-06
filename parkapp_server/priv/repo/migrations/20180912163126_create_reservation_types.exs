defmodule Parkapp.Repo.Migrations.CreateReservationTypes do
  use Ecto.Migration

  def up do
    create table(:reservation_types, primary_key: false) do
      add(:id, :id, primary_key: true)
      add(:name, :string, null: false)
      add(:description, :string, null: false)

      timestamps()
    end

    flush()

    execute("""
      INSERT INTO reservation_types (id, name, description, inserted_at, updated_at)
      VALUES (1, 'Single-use Reservation', 'Reserves a spot on the park (Rotation ticket)', now(), now())
    """)
  end

  def down do
    drop(table(:reservation_types))
  end
end
