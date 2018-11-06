defmodule Parkapp.Repo.Migrations.AddBookedReservationType do
  use Ecto.Migration

  @new_reservation_type_id 2

  def up do
    execute("""
      INSERT INTO reservation_types (id, name, description, inserted_at, updated_at)
      VALUES (#{@new_reservation_type_id}, 'Booked Reservation', 'Books a spot on the park', now(), now())
    """)
  end

  def down do
    execute("""
      DELETE FROM reservation_types WHERE ID = #{@new_reservation_type_id}
    """)
  end
end
