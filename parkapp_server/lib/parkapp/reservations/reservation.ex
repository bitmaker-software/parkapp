defmodule Parkapp.Reservations.Reservation do
  use Ecto.Schema
  import Ecto.Changeset

  alias Parkapp.Reservations.{ReservationType, ReservationStatus}
  alias Parkapp.Auth.Device

  schema "reservations" do
    field(:amount, :string)
    field(:context_token, :string)
    field(:barcode, :string)
    field(:locator, :string)
    field(:cancelled, :boolean, default: false)
    field(:cancelled_at, :utc_datetime)
    field(:reservation_start_time, :utc_datetime)
    field(:parking_start_time, :utc_datetime)
    field(:payment1_time, :utc_datetime)
    field(:parking_payment_time, :utc_datetime)

    belongs_to(:reservation_type, ReservationType)
    belongs_to(:reservation_status, ReservationStatus)
    belongs_to(:device, Device, references: :device_id, type: Ecto.UUID)

    timestamps()
  end

  @doc false
  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [
      :barcode,
      :locator,
      :device_id,
      :reservation_start_time,
      :reservation_type_id,
      :reservation_status_id,
      :cancelled,
      :cancelled_at
    ])
    |> validate_required([
      :barcode,
      :locator,
      :device_id,
      :reservation_start_time,
      :reservation_type_id,
      :reservation_status_id
    ])
    |> foreign_key_constraint(:device_id)
    |> foreign_key_constraint(:reservation_type_id)
    |> foreign_key_constraint(:reservation_status_id)
  end

  @doc false
  def inpark_changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:parking_start_time])
    |> validate_required([:parking_start_time])
  end

  @doc false
  def revert_inpark_changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:parking_start_time])
    |> force_change(:parking_start_time, nil)
  end

  @doc false
  def payment1_changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:context_token, :amount, :payment1_time])
    |> validate_required([:context_token, :amount, :payment1_time])
  end

  @doc false
  def revert_payment1_changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:context_token, :amount, :payment1_time])
    |> force_change(:context_token, nil)
    |> force_change(:amount, nil)
    |> force_change(:payment1_time, nil)
  end

  @doc false
  def payment2_changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:parking_payment_time])
    |> validate_required([:parking_payment_time])
  end

  @doc false
  def revert_payment2_changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:parking_payment_time])
    |> force_change(:parking_payment_time, nil)
  end
end
