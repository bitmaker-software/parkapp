defmodule Parkapp.Reservations.ReservationStatusHistory do
  use Ecto.Schema
  import Ecto.Changeset

  alias Parkapp.Reservations.{Reservation, ReservationStatus}

  schema "reservation_status_history" do
    field(:transitioned_at, :utc_datetime)
    field(:active, :boolean)

    belongs_to(:reservation, Reservation)
    belongs_to(:previous_reservation_status, ReservationStatus)
    belongs_to(:next_reservation_status, ReservationStatus)

    timestamps()
  end

  @doc false
  def changeset(reservation_status_history, attrs) do
    reservation_status_history
    |> cast(attrs, [:transitioned_at, :reservation_id, :previous_reservation_status_id, :next_reservation_status_id, :active])
    |> validate_required([:transitioned_at, :reservation_id, :next_reservation_status_id, :active])
    |> foreign_key_constraint(:reservation_id)
    |> foreign_key_constraint(:previous_reservation_status_id)
    |> foreign_key_constraint(:next_reservation_status_id)
  end
end
