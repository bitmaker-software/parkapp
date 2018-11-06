defmodule Parkapp.Repo.Migrations.CreateReservationStatus do
  use Ecto.Migration

  def up do
    create table(:reservation_status, primary_key: false) do
      add(:id, :id, primary_key: true)
      add(:name, :string, null: false)
      add(:description, :string, null: false)

      timestamps()
    end

    flush()

    execute("""
      INSERT INTO reservation_status (id, name, description, inserted_at, updated_at)
      VALUES (1, 'Open', 'Initial state. Reservation is created.', now(), now())
    """)
    execute("""
      INSERT INTO reservation_status (id, name, description, inserted_at, updated_at)
      VALUES (2, 'In Park', 'User has entered the park.', now(), now())
    """)
    execute("""
      INSERT INTO reservation_status (id, name, description, inserted_at, updated_at)
      VALUES (4, 'External Payment', 'Second state in the payment workflow completed.', now(), now())
    """)
    execute("""
      INSERT INTO reservation_status (id, name, description, inserted_at, updated_at)
      VALUES (5, 'Payment2', 'Third state in the payment workflow completed.', now(), now())
    """)
    execute("""
      INSERT INTO reservation_status (id, name, description, inserted_at, updated_at)
      VALUES (6, 'Closed', 'User has left the park.', now(), now())
    """)
  end

  def down do
    drop(table(:reservation_status))
  end
end
