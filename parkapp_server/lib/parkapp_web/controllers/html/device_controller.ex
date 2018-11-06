defmodule ParkappWeb.HTML.DeviceController do
  use ParkappWeb, :controller

  alias Parkapp.Auth.{
    Devices,
    Device
  }

  def index(conn, _params) do
    devices = Devices.list_devices()
    render(conn, "index.html", devices: devices)
  end

  def generate_new(conn, _params) do
    create_device(conn, %{"device_id" => Ecto.UUID.generate()})
  end

  def new(conn, _params) do
    changeset = Devices.change_base_device(%Device{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"device" => device_params}) do
    create_device(conn, device_params)
  end

  defp create_device(conn, params) do
    Map.put(params, "key", "Some Key")
    |> Devices.create_device()
    |> case do
      {:ok, device} ->
        conn
        |> put_flash(:info, "Device created successfully.")
        |> redirect(to: device_path(conn, :show, device))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    device = Devices.get_device!(id)
    render(conn, "show.html", device: device)
  end

  def edit(conn, %{"id" => id}) do
    device = Devices.get_device!(id)
    changeset = Devices.change_base_device(device)
    render(conn, "edit.html", device: device, changeset: changeset)
  end

  def update(conn, %{"id" => id, "device" => device_params}) do
    device = Devices.get_device!(id)

    case Devices.update_device_base(device, device_params) do
      {:ok, device} ->
        conn
        |> put_flash(:info, "Device updated successfully.")
        |> redirect(to: device_path(conn, :show, device))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", device: device, changeset: changeset)
    end
  end

  #
  # def delete(conn, %{"id" => id}) do
  #   device = Devices.get_device!(id)
  #   {:ok, _device} = Devices.delete_device(device)
  #
  #   conn
  #   |> put_flash(:info, "Device deleted successfully.")
  #   |> redirect(to: device_path(conn, :index))
  # end
end
