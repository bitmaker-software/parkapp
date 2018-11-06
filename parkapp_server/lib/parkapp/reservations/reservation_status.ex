defmodule Parkapp.Reservations.ReservationStatus do
  use Ecto.Schema
  import Ecto.Changeset


  schema "reservation_status" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(reservation_status, attrs) do
    reservation_status
    |> cast(attrs, [:name, :description, :id])
    |> validate_required([:name, :description, :id])
  end
end

defmodule Parkapp.Reservations.ReservationStatus.Enum do
  @moduledoc """
    Enum for reservation status
  """

  def open(), do: 1
  def in_park(), do: 2
  def external_payment(), do: 4
  def payment2(), do: 5
  def closed(), do: 6
end
