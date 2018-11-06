defmodule Parkapp.Auth.Device do
  @moduledoc """
  The Device module contains the Device Schema and changesets.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:device_id, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :device_id}
  @derive {Poison.Encoder, only: [:device_id, :key, :secret]}

  schema "devices" do
    # text, in the migration
    field(:key, :string)
    # text, in the migration
    field(:secret, :string)

    timestamps()
  end

  @doc false
  def base_changeset(device, attrs) do
    device
    |> cast(attrs, [:device_id, :key])
    |> base_validation
  end

  @doc false
  def set_secret_changeset(device, attrs) do
    device
    |> cast(attrs, [:device_id, :key, :secret])
    |> base_validation
    |> validate_required([:secret])
  end

  @doc false
  def base_validation(changeset) do
    changeset
    |> validate_required([:device_id, :key])
    |> unique_constraint(:device_id, name: "devices_pkey")
  end
end
