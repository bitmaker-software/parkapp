defmodule Parkapp.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Parkapp.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Parkapp.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Parkapp.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Parkapp.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  alias Parkapp.Auth.Devices

  @public_key "MIIBCgKCAQEAjMeo71xLBPFZOWXbZ8rUbDjJzC/p6gk9JLR4RjqJEb9dnSm+qAbA8fG4SKguHJgs5BxJEMJmm7kG1C7GgTPlvFQdhdNRjw23aC34CTEaOuDznuH6y8fjqwrA6gu7ECg/gtACc+R87ArS/mn5w9aeLQcXBKzr3Gi8Yc1Ws9eaa3ukNSVC+GV9SfMWhS9JeiEUc00VbH3UgPFogHOya7PF2ddUckYN4pgxnZ0X39Prx5s/X1oA9lSolVbGxnbQfk4NPgEoKNLj90vQknJN7oPd50DcH3tlSKaOBu2lK1fcJs6Q7cTSukT/kzZxI8uojPpgjaE7fsZwvAsis0ScCabsxQIDAQAB"
  @device_id Ecto.UUID.generate()

  @secret "yOW3UGXIYLHYUOqfcb0xo4aZk8vXU3ROqBa0yt637n5wddhR88hX720aEt3TixSRGBZtykixQuxBTz1zgSAvVLOiS7lzxEAJ7hPuyCC4FdJ4VlfpEkjFc38iN3If1U_I1s1d5irL5sBQHEKi5hsa1TcSj9Gab-pXRux4lITO7SrYSz6DqDmjkW24GpIaU6O0HtxoZAW-mtB4I9cXDFAnIccbgdqyfk0vAXD8zreMAjsroLJFTjb4Wj5GXXhle_sD"
  @encrypted_secret "SvYl1oOnKCWq7Z463QdEM/7VvEGwzyajve5AT2RXuekIiWTssT5ZJd3vdYMBK3D7kZUFkDA8fAo3s8+flFFoi6sugSsu9x04cmEA3godnU/LQOv77ZzxZwPyJPHcjJqM/H2PZI2dgTIsMclFJk/D6QMKK2ehXsil6VTW9wus/7eSGSthCCAb+X5gt8N0iaw3HyUcfJA3UW/lcvV/tX8FQAPrU91T+xOudDwHwNgrRXXnHlifhhjgzSJitmBswQ3k3jGf5RWgV0vOecuY7yumY0sTE0TXmWK9L7igIr4ZHTI1I6xuk5tCtW8tGGyW6KHdCzJAvdDRLg6gq1PgGUP7SQ=="

  @attrs %{device_id: @device_id, key: @public_key}

  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      Enum.into(attrs, @attrs)
      |> Devices.create_device()

    device = Devices.get_device!(device.device_id)
    {:ok, device} = Devices.update_device_secret(device, %{secret: @secret})
    device
  end

  def get_encrypted_secret(), do: @encrypted_secret

  def get_basic_device_attrs(), do: @attrs

  alias Parkapp.ReservationsContext

  alias Parkapp.Reservations.{
    ReservationType,
    Reservation
  }

  def reservation_fkey_fix() do
    {
      ReservationType.Enum.single_use(),
      device_fixture().device_id
    }
  end

  def reservation_fixture() do
    {type_id, device_id} = reservation_fkey_fix()

    {:ok, %Reservation{} = reservation} =
      ReservationsContext.create_reservation_initial_state(%{
        reservation_type_id: type_id,
        device_id: device_id,
        barcode: "some barcode",
        locator: "some locator",
        reservation_start_time: DateTime.utc_now()
      })

    reservation
  end

  def reservation_fixture(device_id) do
    {:ok, %Reservation{} = reservation} =
      ReservationsContext.create_reservation_initial_state(%{
        reservation_type_id: ReservationType.Enum.single_use(),
        device_id: device_id,
        barcode: "some barcode",
        locator: "some locator",
        reservation_start_time: DateTime.utc_now()
      })

    reservation
  end
end
