defmodule Parkapp.Auth.Devices do
  @moduledoc """
  The Devices module contains the Device/DB communication related methods.
  """

  alias Parkapp.Repo
  alias Parkapp.Auth.Device

  @doc """
  Returns the list of devices.

  ## Examples

      iex> list_devices()
      [%Device{}, ...]

  """
  def list_devices do
    Repo.all(Device)
  end

  @doc """
  Creates a device.

  ## Examples

      iex> create_device(%{field: value})
      {:ok, %Device{}}

      iex> create_device(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_device(attrs) do
    %Device{}
    |> Device.base_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a device base.

  ## Examples

      iex> update_device_base(device, %{field: new_value})
      {:ok, %Device{}}

      iex> update_device_base(device, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_device_base(device, attrs) do
    device
    |> Device.base_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a device secret.

  ## Examples

      iex> update_device_secret(device, %{field: new_value})
      {:ok, %Device{}}

      iex> update_device_secret(device, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_device_secret(device, attrs) do
    device
    |> Device.set_secret_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets a single device.

  Returns nil if there is no device with the given id

  ## Examples

      iex> get_device(123)
      %Device{}

      iex> get_device(456)
      nil

  """
  def get_device(device_id) do
    Repo.get(Device, device_id)
  end

  @doc """
  Gets a single device.

  Raises Ecto.NoResultsError if the device does not exist

  ## Examples

      iex> get_device(123)
      %Device{}

      iex> get_device(456)
      Ecto.NoResultsError

  """
  def get_device!(device_id) do
    Repo.get!(Device, device_id)
  end

  @doc """
  Gets a field from a single device.

  Returns nil if there is no device with the given id

  ## Examples

      iex> get_device_field(123, :field)
      value

      iex> get_device_field(456, :field)
      nil

  """
  def get_device_field(device_id, field) when is_atom(field) do
    case get_device(device_id) do
      nil -> nil
      device -> Map.get(device, field)
    end
  end

  @doc """
  Deletes a Device.

  ## Examples

      iex> delete_device(device)
      {:ok, %Device{}}

      iex> delete_device(device)
      {:error, %Ecto.Changeset{}}

  """
  def delete_device(%Device{} = device) do
    Repo.delete(device)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking device changes.
  Uses the base changeset.

  ## Examples

      iex> change_base_device(device)
      %Ecto.Changeset{source: %Device{}}

  """
  def change_base_device(%Device{} = device, attrs \\ %{}) do
    Device.base_changeset(device, attrs)
  end
end
