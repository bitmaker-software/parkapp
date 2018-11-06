defmodule Parkapp.DevicesTest do
  use Parkapp.DataCase

  alias Parkapp.Auth.Devices

  describe "Devices" do
    @valid_attrs %{device_id: Ecto.UUID.generate(), key: "test_key"}
    @other_valid_attrs %{device_id: Ecto.UUID.generate(), key: "test_key"}

    def local_device_fixture(attrs \\ %{}) do
      {:ok, device} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Devices.create_device()

      device
    end

    test "list_devices/0 returns all devices" do
      device = local_device_fixture()
      assert Devices.list_devices() == [device]
    end

    test "get_device_field/2 returns the field of the given device" do
      field = :key
      device = local_device_fixture()

      assert(Devices.get_device_field(device.device_id, field) == Map.get(device, field))
    end

    test "create_device/1 should error if device_id is not unique" do
      device = local_device_fixture()

      assert {:error, %Ecto.Changeset{} = changeset} =
               Devices.create_device(%{device_id: device.device_id, key: "another test key"})

      assert(errors_on(changeset) == %{device_id: ["has already been taken"]})
    end

    test "update_device_base/1 should error if device_id is not unique" do
      device = local_device_fixture()
      device_2 = local_device_fixture(@other_valid_attrs)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Devices.update_device_base(device, %{device_id: device_2.device_id})

      assert(errors_on(changeset) == %{device_id: ["has already been taken"]})
      assert Devices.get_device(device.device_id).device_id == device.device_id
    end

    test "change_base_device/1 returns a device changeset" do
      device = local_device_fixture()
      assert %Ecto.Changeset{} = Devices.change_base_device(device)
    end
  end
end
