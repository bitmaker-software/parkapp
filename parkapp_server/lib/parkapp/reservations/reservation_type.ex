defmodule Parkapp.Reservations.ReservationType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reservation_types" do
    field(:description, :string)
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(reservation_type, attrs) do
    reservation_type
    |> cast(attrs, [:name, :description, :id])
    |> validate_required([:name, :description, :id])
  end
end

defmodule Parkapp.Reservations.ReservationType.Enum do
  @moduledoc """
    Enum for reservation types
  """

  def single_use(), do: 1
  def booked(), do: 2
end

defmodule Parkapp.Reservations.ReservationType.Enum.Guards do
  @moduledoc """
    Custom guards for the reservation's context
  """

  defguard is_reservation_type(type) when type in [1, 2]
end

defmodule Parkapp.Reservations.ReservationType.ConfigurationStruct do
  @moduledoc """
    Factory to build reservation type configurations
  """

  import Parkapp.Reservations.ReservationType.Enum.Guards

  defstruct reservation_type: nil, product_type: 1, delay_activation: 0

  @doc """
    Builds the correct configuration struct given the reservation type
  """
  @spec get_configuration(ReservationType) :: __MODULE__ | :error
  def get_configuration(reservation_type_id) when is_reservation_type(reservation_type_id) do
    case reservation_type_id do
      1 ->
        %__MODULE__{reservation_type: reservation_type_id}

      2 ->
        %__MODULE__{reservation_type: reservation_type_id, delay_activation: 30}

      _else ->
        :error
    end
  end
end
