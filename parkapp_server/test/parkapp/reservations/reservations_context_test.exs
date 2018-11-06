defmodule Parkapp.ReservationsTest do
  use Parkapp.DataCase

  alias Parkapp.ReservationsContext

  alias Parkapp.Reservations.{
    ReservationType,
    ReservationStatus,
    Reservation,
    ReservationStatusHistory
  }

  describe "reservation_types" do
    test "list_reservation_types/0 returns all reservation_types" do
      assert ReservationsContext.list_reservation_types() |> length() == 2
    end

    test "get_reservation_type!/1 returns the reservation_type with given id" do
      assert %ReservationType{} =
               reservation_type =
               ReservationsContext.get_reservation_type!(ReservationType.Enum.single_use())

      assert reservation_type.id == ReservationType.Enum.single_use()
      assert reservation_type.name == "Single-use Reservation"
    end
  end

  describe "reservation_status" do
    test "list_reservation_status/0 returns all reservation_status" do
      assert ReservationsContext.list_reservation_status() |> length() == 5
    end

    test "get_reservation_status!/1 returns the reservation_status with given id" do
      assert %ReservationStatus{} =
               reservation_status =
               ReservationsContext.get_reservation_status!(ReservationStatus.Enum.open())

      assert reservation_status.id == ReservationStatus.Enum.open()
      assert reservation_status.name == "Open"
    end
  end

  describe "reservations" do
    @valid_attrs %{
      amount: "some amount",
      barcode: "some barcode",
      context_token: "some context_token",
      payment1_time: DateTime.utc_now(),
      locator: "some locator",
      reservation_start_time: DateTime.utc_now()
    }
    @updated_payment1_time DateTime.utc_now()
    @update_attrs %{
      amount: "some updated amount",
      barcode: "some updated barcode",
      context_token: "some updated context_token",
      payment1_time: @updated_payment1_time,
      locator: "some updated locator",
      reservation_start_time: DateTime.utc_now()
    }
    @inpark_attrs %{
      parking_start_time: DateTime.utc_now()
    }
    @invalid_attrs %{
      amount: nil,
      barcode: nil,
      context_token: nil,
      payment1_time: nil,
      locator: nil,
      reservation_start_time: nil
    }

    def local_reservation_fkey_fix() do
      {
        ReservationStatus.Enum.open(),
        ReservationType.Enum.single_use(),
        device_fixture().device_id
      }
    end

    def local_reservation_fixture(attrs \\ %{}) do
      {status_id, type_id, device_id} = local_reservation_fkey_fix()

      {:ok, reservation} =
        attrs
        |> Map.put(:reservation_status_id, status_id)
        |> Map.put(:reservation_type_id, type_id)
        |> Map.put(:device_id, device_id)
        |> Enum.into(@valid_attrs)
        |> ReservationsContext.create_reservation()

      reservation
    end

    test "list_reservations/0 returns all reservations" do
      reservation = local_reservation_fixture()
      assert ReservationsContext.list_reservations() == [reservation]
    end

    test "list_reservations_order_by_recent/0 returns all reservations ordered by updated_at field" do
      reservation = local_reservation_fixture()

      {:ok, reservation_new} =
        Map.put(%{}, :reservation_status_id, reservation.reservation_status_id)
        |> Map.put(:reservation_type_id, reservation.reservation_type_id)
        |> Map.put(:device_id, device_fixture(%{device_id: Ecto.UUID.generate()}).device_id)
        |> Enum.into(@valid_attrs)
        |> ReservationsContext.create_reservation()

      assert ReservationsContext.list_reservations_order_by_recent() == [
               reservation_new,
               reservation
             ]
    end

    test "list_reservations_order_by_inserted/0 returns all reservations ordered by inserted_at field" do
      reservation = local_reservation_fixture()

      {:ok, reservation_new} =
        Map.put(%{}, :reservation_status_id, reservation.reservation_status_id)
        |> Map.put(:reservation_type_id, reservation.reservation_type_id)
        |> Map.put(:device_id, device_fixture(%{device_id: Ecto.UUID.generate()}).device_id)
        |> Enum.into(@valid_attrs)
        |> ReservationsContext.create_reservation()

      assert ReservationsContext.list_reservations_order_by_inserted() == [
               reservation_new,
               reservation
             ]
    end

    test "get_reservation!/1 returns the reservation with given id" do
      reservation = local_reservation_fixture()
      assert ReservationsContext.get_reservation!(reservation.id) == reservation
    end

    test "get_reservation/1 returns the reservation with given id" do
      reservation = local_reservation_fixture()
      assert ReservationsContext.get_reservation(reservation.id) == reservation
    end

    test "get_reservation_by_barcode/1 returns the reservation with given barcode" do
      reservation = local_reservation_fixture()
      assert ReservationsContext.get_reservation_by_barcode(reservation.barcode) == reservation
    end

    test "get_reservation_by_barcode/1 returns nil if the reservation does not exist" do
      assert ReservationsContext.get_reservation_by_barcode("non existing barcode") |> is_nil()
    end

    test "get_reservation_by_locator/1 returns the reservation with given locator" do
      reservation = local_reservation_fixture()
      assert ReservationsContext.get_reservation_by_locator(reservation.locator) == reservation
    end

    test "get_reservation_by_locator/1 returns nil if the reservation does not exist" do
      assert ReservationsContext.get_reservation_by_locator("non existing locator") |> is_nil()
    end

    test "get_last_cancelled_reservation/1 returns the last cancelled reservation for the given device 1" do
      device =
        device_fixture(%{
          device_id: Ecto.UUID.generate()
        })

      reservation_fixture(device.device_id)
      reservation = reservation_fixture()
      assert {:ok, reservation} = ReservationsContext.cancel_reservation(reservation)

      assert ReservationsContext.get_last_cancelled_reservation(reservation.device_id) ==
               reservation
    end

    test "get_last_cancelled_reservation/1 returns the last cancelled reservation for the given device 2" do
      reservation = reservation_fixture()
      assert {:ok, reservation} = ReservationsContext.cancel_reservation(reservation)
      last_reservation = reservation_fixture(reservation.device_id)
      assert {:ok, last_reservation} = ReservationsContext.cancel_reservation(last_reservation)

      assert ReservationsContext.get_last_cancelled_reservation(reservation.device_id) ==
               last_reservation
    end

    test "get_last_cancelled_reservation/1 returns nil if there is no cancelled reservation for the given device" do
      reservation = local_reservation_fixture()

      assert ReservationsContext.get_last_cancelled_reservation(reservation.device_id) |> is_nil()
    end

    test "create_reservation/1 with valid data creates a reservation" do
      {status_id, type_id, device_id} = local_reservation_fkey_fix()

      assert {:ok, %Reservation{} = reservation} =
               Map.put(@valid_attrs, :reservation_status_id, status_id)
               |> Map.put(:reservation_type_id, type_id)
               |> Map.put(:device_id, device_id)
               |> ReservationsContext.create_reservation()

      assert is_nil(reservation.amount)
      assert reservation.barcode == "some barcode"
      assert is_nil(reservation.context_token)
      assert reservation.locator == "some locator"
    end

    test "create_reservation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ReservationsContext.create_reservation(@invalid_attrs)
    end

    test "update_reservation/2 with valid data updates the reservation" do
      reservation = local_reservation_fixture()

      assert {:ok, reservation} =
               ReservationsContext.update_reservation(reservation, @update_attrs)

      assert %Reservation{} = reservation
      assert is_nil(reservation.amount)
      assert reservation.barcode == "some updated barcode"
      assert reservation.locator == "some updated locator"
    end

    test "update_reservation_inpark/2 with valid data updates the reservation" do
      reservation = local_reservation_fixture()

      assert {:ok, reservation} =
               ReservationsContext.update_reservation_inpark(reservation, @inpark_attrs)

      assert %Reservation{} = reservation
      assert reservation.parking_start_time == @inpark_attrs.parking_start_time
    end

    test "update_reservation_after_payment/2 with valid data updates the reservation" do
      reservation = local_reservation_fixture()

      assert {:ok, reservation} =
               ReservationsContext.update_reservation_after_payment1(reservation, @update_attrs)

      assert %Reservation{} = reservation
      assert reservation.amount == "some updated amount"
      assert reservation.barcode == "some barcode"
      assert reservation.context_token == "some updated context_token"
      assert reservation.locator == "some locator"
    end

    test "revert_payment1_values/1 should update the reservation with nil in the payment1 values" do
      reservation = local_reservation_fixture()

      assert {:ok, reservation} =
               ReservationsContext.update_reservation_after_payment1(reservation, @update_attrs)

      assert %Reservation{} = reservation
      assert reservation.amount == "some updated amount"
      assert reservation.context_token == "some updated context_token"
      assert reservation.payment1_time == @updated_payment1_time

      assert {:ok, reservation} = ReservationsContext.revert_payment1_values(reservation)

      assert %Reservation{} = reservation
      assert reservation.amount |> is_nil()
      assert reservation.context_token |> is_nil()
      assert reservation.payment1_time |> is_nil()
    end

    test "revert_payment2_values/1 should update the reservation with nil in the payment1 values" do
      reservation = local_reservation_fixture()
      now = DateTime.utc_now()

      assert {:ok, reservation} =
               ReservationsContext.update_reservation_after_payment2(reservation, %{
                 parking_payment_time: now
               })

      assert %Reservation{} = reservation
      assert reservation.parking_payment_time == now

      assert {:ok, reservation} = ReservationsContext.revert_payment2_values(reservation)

      assert %Reservation{} = reservation
      assert reservation.parking_payment_time |> is_nil()
    end

    test "revert_in_park_values/1 should update the reservation with nil in the inpark values" do
      reservation = reservation_fixture()

      assert reservation.reservation_status_id == ReservationStatus.Enum.open()
      assert reservation.parking_start_time |> is_nil()

      assert {:ok, reservation} =
               ReservationsContext.move_to_in_park_state(reservation, DateTime.utc_now())

      assert %Reservation{} = reservation
      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()
      assert reservation.parking_start_time |> is_nil() == false

      assert {:ok, reservation} = ReservationsContext.revert_in_park_values(reservation)

      assert %Reservation{} = reservation
      assert reservation.parking_start_time |> is_nil()
    end

    test "update_reservation/2 with invalid data returns error changeset" do
      reservation = local_reservation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ReservationsContext.update_reservation(reservation, @invalid_attrs)

      assert reservation == ReservationsContext.get_reservation!(reservation.id)
    end

    test "delete_reservation/1 deletes the reservation" do
      reservation = local_reservation_fixture()
      assert {:ok, %Reservation{}} = ReservationsContext.delete_reservation(reservation)

      assert_raise Ecto.NoResultsError, fn ->
        ReservationsContext.get_reservation!(reservation.id)
      end
    end

    test "change_reservation/1 returns a reservation changeset" do
      reservation = local_reservation_fixture()
      assert %Ecto.Changeset{} = ReservationsContext.change_reservation(reservation)
    end

    test "change_payment_reservation/2 returns a reservation changeset for the payment" do
      reservation = local_reservation_fixture()

      assert %Ecto.Changeset{} =
               changeset = ReservationsContext.change_payment_reservation(reservation)

      assert errors_on(changeset) == %{
               amount: ["can't be blank"],
               context_token: ["can't be blank"],
               payment1_time: ["can't be blank"]
             }

      assert %Ecto.Changeset{} =
               changeset =
               ReservationsContext.change_payment_reservation(reservation, %{
                 context_token: "",
                 amount: "",
                 payment1_time: nil
               })

      assert errors_on(changeset) == %{
               amount: ["can't be blank"],
               context_token: ["can't be blank"],
               payment1_time: ["can't be blank"]
             }
    end
  end

  describe "revervation_status_history" do
    @valid_attrs %{transitioned_at: "2010-04-17 14:00:00.000000Z", active: true}
    @update_attrs %{transitioned_at: "2011-05-18 15:01:01.000000Z", active: false}
    @invalid_attrs %{transitioned_at: nil, active: nil}

    def local_reservation_status_history_fkey_fix() do
      {
        ReservationStatus.Enum.open(),
        ReservationStatus.Enum.in_park(),
        local_reservation_fixture().id
      }
    end

    def local_reservation_status_history_fixture(attrs \\ %{}) do
      {previous_state, next_state, reservation_id} = local_reservation_status_history_fkey_fix()

      {:ok, reservation_status_history} =
        attrs
        |> Map.put(:previous_reservation_status_id, previous_state)
        |> Map.put(:next_reservation_status_id, next_state)
        |> Map.put(:reservation_id, reservation_id)
        |> Enum.into(@valid_attrs)
        |> ReservationsContext.create_reservation_status_history()

      reservation_status_history
    end

    test "list_reservation_status_history/0 returns all revervation_status_history" do
      reservation_status_history = local_reservation_status_history_fixture()
      assert ReservationsContext.list_reservation_status_history() == [reservation_status_history]
    end

    test "get_reservation_status_history!/1 returns the reservation_status_history with given id" do
      reservation_status_history = local_reservation_status_history_fixture()

      assert ReservationsContext.get_reservation_status_history!(reservation_status_history.id) ==
               reservation_status_history
    end

    test "create_reservation_status_history/1 with valid data creates a reservation_status_history" do
      {previous_state, next_state, reservation_id} = local_reservation_status_history_fkey_fix()

      assert {:ok, %ReservationStatusHistory{} = reservation_status_history} =
               Map.put(@valid_attrs, :previous_reservation_status_id, previous_state)
               |> Map.put(:next_reservation_status_id, next_state)
               |> Map.put(:reservation_id, reservation_id)
               |> ReservationsContext.create_reservation_status_history()

      assert reservation_status_history.transitioned_at ==
               DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")

      assert reservation_status_history.active == true
    end

    test "create_reservation_status_history/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               ReservationsContext.create_reservation_status_history(@invalid_attrs)
    end

    test "update_reservation_status_history/2 with valid data updates the reservation_status_history" do
      reservation_status_history = local_reservation_status_history_fixture()

      assert {:ok, reservation_status_history} =
               ReservationsContext.update_reservation_status_history(
                 reservation_status_history,
                 @update_attrs
               )

      assert %ReservationStatusHistory{} = reservation_status_history

      assert reservation_status_history.transitioned_at ==
               DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")

      assert reservation_status_history.active == false
    end

    test "update_reservation_status_history/2 with invalid data returns error changeset" do
      reservation_status_history = local_reservation_status_history_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ReservationsContext.update_reservation_status_history(
                 reservation_status_history,
                 @invalid_attrs
               )

      assert reservation_status_history ==
               ReservationsContext.get_reservation_status_history!(reservation_status_history.id)
    end

    test "delete_reservation_status_history/1 deletes the reservation_status_history" do
      reservation_status_history = local_reservation_status_history_fixture()

      assert {:ok, %ReservationStatusHistory{}} =
               ReservationsContext.delete_reservation_status_history(reservation_status_history)

      assert_raise Ecto.NoResultsError, fn ->
        ReservationsContext.get_reservation_status_history!(reservation_status_history.id)
      end
    end

    test "change_reservation_status_history/1 returns a reservation_status_history changeset" do
      reservation_status_history = local_reservation_status_history_fixture()

      assert %Ecto.Changeset{} =
               ReservationsContext.change_reservation_status_history(reservation_status_history)
    end
  end

  describe "Reservations API" do
    alias Parkapp.Logging

    @context_token "some context token"
    @amount "some amount"
    @payment1_time DateTime.utc_now()

    def assert_open_step() do
      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.create_reservation_initial_state(%{
                 locator: "some locator",
                 barcode: "some barcode",
                 device_id: device_fixture().device_id,
                 reservation_type_id: ReservationType.Enum.single_use(),
                 reservation_start_time: DateTime.utc_now()
               })

      assert reservation.reservation_status_id == ReservationStatus.Enum.open()

      assert %ReservationStatusHistory{} =
               reservation_status_history =
               ReservationsContext.get_active_reservation_history(reservation.id)

      assert reservation_status_history.active == true
      assert is_nil(reservation_status_history.previous_reservation_status_id)

      assert reservation_status_history.next_reservation_status_id ==
               ReservationStatus.Enum.open()

      reservation
    end

    def assert_in_park_step(reservation) do
      assert previous_reservation_status_history_id =
               ReservationsContext.get_active_reservation_history(reservation.id).id

      now = DateTime.utc_now()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.move_to_in_park_state(reservation, now)

      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()
      assert reservation.parking_start_time == now

      assert %ReservationStatusHistory{} =
               deactivated_reservation_status_history =
               ReservationsContext.get_reservation_status_history!(
                 previous_reservation_status_history_id
               )

      assert deactivated_reservation_status_history.active == false

      assert %ReservationStatusHistory{} =
               reservation_status_history =
               ReservationsContext.get_active_reservation_history(reservation.id)

      assert reservation_status_history.active == true

      assert reservation_status_history.previous_reservation_status_id ==
               ReservationStatus.Enum.open()

      assert reservation_status_history.next_reservation_status_id ==
               ReservationStatus.Enum.in_park()

      reservation
    end

    def assert_payment1_step(reservation) do
      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.update_reservation_after_payment1(reservation, %{
                 context_token: @context_token,
                 amount: @amount,
                 payment1_time: @payment1_time
               })

      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()

      reservation
    end

    def assert_external_payment_step(reservation) do
      assert previous_reservation_status_history_id =
               ReservationsContext.get_active_reservation_history(reservation.id).id

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.move_to_external_payment_state(reservation)

      assert reservation.reservation_status_id == ReservationStatus.Enum.external_payment()

      assert %ReservationStatusHistory{} =
               deactivated_reservation_status_history =
               ReservationsContext.get_reservation_status_history!(
                 previous_reservation_status_history_id
               )

      assert deactivated_reservation_status_history.active == false

      assert %ReservationStatusHistory{} =
               reservation_status_history =
               ReservationsContext.get_active_reservation_history(reservation.id)

      assert reservation_status_history.active == true

      assert reservation_status_history.previous_reservation_status_id ==
               ReservationStatus.Enum.in_park()

      assert reservation_status_history.next_reservation_status_id ==
               ReservationStatus.Enum.external_payment()

      reservation
    end

    def assert_payment2_step(reservation) do
      assert previous_reservation_status_history_id =
               ReservationsContext.get_active_reservation_history(reservation.id).id

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.move_to_payment2_state(
                 reservation,
                 DateTime.utc_now()
               )

      assert reservation.reservation_status_id == ReservationStatus.Enum.payment2()

      assert %ReservationStatusHistory{} =
               deactivated_reservation_status_history =
               ReservationsContext.get_reservation_status_history!(
                 previous_reservation_status_history_id
               )

      assert deactivated_reservation_status_history.active == false

      assert %ReservationStatusHistory{} =
               reservation_status_history =
               ReservationsContext.get_active_reservation_history(reservation.id)

      assert reservation_status_history.active == true

      assert reservation_status_history.previous_reservation_status_id ==
               ReservationStatus.Enum.external_payment()

      assert reservation_status_history.next_reservation_status_id ==
               ReservationStatus.Enum.payment2()

      reservation
    end

    def assert_closed_step(reservation) do
      assert previous_reservation_status_history_id =
               ReservationsContext.get_active_reservation_history(reservation.id).id

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.move_to_closed_state(reservation)

      assert reservation.reservation_status_id == ReservationStatus.Enum.closed()

      assert %ReservationStatusHistory{} =
               deactivated_reservation_status_history =
               ReservationsContext.get_reservation_status_history!(
                 previous_reservation_status_history_id
               )

      assert deactivated_reservation_status_history.active == false

      assert %ReservationStatusHistory{} =
               reservation_status_history =
               ReservationsContext.get_active_reservation_history(reservation.id)

      assert reservation_status_history.active == true

      assert reservation_status_history.previous_reservation_status_id ==
               ReservationStatus.Enum.payment2()

      assert reservation_status_history.next_reservation_status_id ==
               ReservationStatus.Enum.closed()

      reservation
    end

    test "reservation status workflow" do
      assert %Reservation{} = reservation = assert_open_step()
      assert %Reservation{} = reservation = assert_in_park_step(reservation)
      assert %Reservation{} = reservation = assert_external_payment_step(reservation)
      assert %Reservation{} = reservation = assert_payment2_step(reservation)
      assert %Reservation{} = reservation = assert_closed_step(reservation)

      assert ReservationsContext.get_current_reservation(reservation.device_id) |> is_nil()
    end

    test "revert_from_external_payment_to_in_park/1 should revert the payment1 values and set status to in_park" do
      assert %Reservation{} = reservation = assert_open_step()
      assert %Reservation{} = reservation = assert_in_park_step(reservation)
      assert %Reservation{} = reservation = assert_payment1_step(reservation)
      assert %Reservation{} = reservation = assert_external_payment_step(reservation)
      assert reservation.reservation_status_id == ReservationStatus.Enum.external_payment()
      assert reservation.amount == @amount
      assert reservation.context_token == @context_token
      assert reservation.payment1_time == @payment1_time

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.revert_from_external_payment_to_in_park(reservation)

      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()
      assert reservation.amount |> is_nil()
      assert reservation.context_token |> is_nil()
      assert reservation.payment1_time |> is_nil()
    end

    test "revert_from_external_payment_to_in_park/1 should error if status is not external_payment" do
      assert %Reservation{} = reservation = assert_open_step()
      assert %Reservation{} = reservation = assert_in_park_step(reservation)
      assert %Reservation{} = reservation = assert_payment1_step(reservation)
      assert %Reservation{} = reservation = assert_external_payment_step(reservation)
      assert reservation.reservation_status_id == ReservationStatus.Enum.external_payment()
      assert reservation.amount == @amount
      assert reservation.context_token == @context_token
      assert reservation.payment1_time == @payment1_time

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.move_reservation_from_to(
                 reservation,
                 ReservationStatus.Enum.external_payment(),
                 ReservationStatus.Enum.in_park()
               )

      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()

      result = ReservationsContext.revert_from_external_payment_to_in_park(reservation)

      assert result |> is_nil()
    end

    test "close_reservation/1 should close any reservation" do
      assert %Reservation{} = reservation = assert_open_step()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.close_reservation(reservation)

      assert reservation.reservation_status_id == ReservationStatus.Enum.closed()
    end

    test "cancel_reservation/1 should cancels any reservation" do
      assert %Reservation{} = reservation = assert_open_step()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.cancel_reservation(reservation)

      assert reservation.reservation_status_id == ReservationStatus.Enum.closed()
      assert reservation.cancelled
      assert reservation.cancelled_at |> is_nil() == false
    end

    test "reservation open step must fail if attrs are invalid" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               ReservationsContext.create_reservation_initial_state(%{})

      assert errors_on(changeset) == %{
               barcode: ["can't be blank"],
               device_id: ["can't be blank"],
               locator: ["can't be blank"],
               reservation_type_id: ["can't be blank"],
               reservation_start_time: ["can't be blank"]
             }
    end

    test "reservation move_to_in_park step must fail if attrs are invalid" do
      assert %Reservation{} = reservation = assert_open_step()

      assert {:error, %Ecto.Changeset{} = changeset} =
               ReservationsContext.move_to_in_park_state(reservation, "")

      assert errors_on(changeset) == %{parking_start_time: ["can't be blank"]}

      assert {:error, %Ecto.Changeset{} = changeset} =
               ReservationsContext.move_to_in_park_state(reservation, "18-20-2018")

      assert errors_on(changeset) == %{parking_start_time: ["is invalid"]}
    end

    test "reservation move_to_external_payment step must fail if reservation is in the incorrect status" do
      assert %Reservation{} = reservation = assert_open_step()

      result = ReservationsContext.move_to_external_payment_state(reservation)

      assert is_nil(result)
    end

    test "reservation status change must fail if reservation is not on the correct base state" do
      assert %Reservation{} = reservation = assert_open_step()

      assert ReservationsContext.move_to_payment2_state(reservation, DateTime.utc_now())
             |> is_nil()
    end

    test "move_reservation_from_to/3 returns nil if both status are the same" do
      assert %Reservation{} = reservation = assert_open_step()

      assert ReservationsContext.move_reservation_from_to(
               reservation,
               ReservationStatus.Enum.open(),
               ReservationStatus.Enum.open()
             )
             |> is_nil()
    end

    test "move_reservation_from_to/3 returns nil if previous state is invalid" do
      assert %Reservation{} = reservation = assert_open_step()

      assert ReservationsContext.move_reservation_from_to(
               reservation,
               -1,
               ReservationStatus.Enum.open()
             )
             |> is_nil()
    end

    test "move_reservation_from_to/3 returns nil if next state is invalid" do
      assert %Reservation{} = reservation = assert_open_step()

      assert {:error, %Ecto.Changeset{} = changeset} =
               ReservationsContext.move_reservation_from_to(
                 reservation,
                 ReservationStatus.Enum.open(),
                 -1
               )

      assert errors_on(changeset) == %{reservation_status_id: ["does not exist"]}
    end

    test "reservation status change must fail if parking_payment_time is invalid" do
      assert %Reservation{} = reservation = assert_open_step()

      assert {:error, %Ecto.Changeset{} = changeset} =
               ReservationsContext.move_to_payment2_state(reservation, nil)

      assert errors_on(changeset) == %{parking_payment_time: ["can't be blank"]}
    end

    test "get_active_reservation_history/1 returns the active reservation history for the given reservation_id" do
      reservation_status_history = local_reservation_status_history_fixture()

      assert %ReservationStatusHistory{} =
               reservation_status_history_retrieved =
               ReservationsContext.get_active_reservation_history(
                 reservation_status_history.reservation_id
               )

      assert reservation_status_history == reservation_status_history_retrieved
    end

    test "get_active_reservation_history/1 returns nil if it does not find an active history" do
      reservation_status_history = local_reservation_status_history_fixture(%{active: false})

      reservation_status_history_retrieved =
        ReservationsContext.get_active_reservation_history(
          reservation_status_history.reservation_id
        )

      assert is_nil(reservation_status_history_retrieved)
    end

    test "get_current_reservation/1 returns the current active reservation for the given device_id" do
      reservation_status_history = local_reservation_status_history_fixture()

      reservation =
        ReservationsContext.get_reservation!(reservation_status_history.reservation_id)

      assert %Reservation{} =
               current_reservation =
               ReservationsContext.get_current_reservation(reservation.device_id)

      assert reservation == current_reservation
    end

    test "get_current_reservation/1 returns nil if history is false" do
      reservation_status_history = local_reservation_status_history_fixture(%{active: false})

      reservation =
        ReservationsContext.get_reservation!(reservation_status_history.reservation_id)

      current_reservation = ReservationsContext.get_current_reservation(reservation.device_id)

      assert is_nil(current_reservation)
    end

    test "get_current_reservation/1 returns nil if reservation is in closed status" do
      reservation_status_history = local_reservation_status_history_fixture()

      {:ok, reservation} =
        ReservationsContext.get_reservation!(reservation_status_history.reservation_id)
        |> ReservationsContext.update_reservation(%{
          reservation_status_id: ReservationStatus.Enum.closed()
        })

      current_reservation = ReservationsContext.get_current_reservation(reservation.device_id)

      assert is_nil(current_reservation)
    end

    test "deactivate_reservation_status_history/1" do
      reservation_status_history = local_reservation_status_history_fixture()

      assert {:ok, %ReservationStatusHistory{} = deactivated_reservation_status_history} =
               ReservationsContext.deactivate_reservation_status_history(
                 reservation_status_history.reservation_id
               )

      assert reservation_status_history.active == true
      assert deactivated_reservation_status_history.active == false
      assert reservation_status_history.id == deactivated_reservation_status_history.id
    end

    test "deactivate_reservation_status_history/1 returns nil if history is inactive" do
      reservation_status_history = local_reservation_status_history_fixture(%{active: false})
      assert reservation_status_history.active == false

      deactivated_reservation_status_history =
        ReservationsContext.deactivate_reservation_status_history(
          reservation_status_history.reservation_id
        )

      assert is_nil(deactivated_reservation_status_history)
    end

    test "delete_all_reservations/0 should delete every reservation and respective history" do
      assert %Reservation{} = reservation = assert_open_step()
      assert %Reservation{} = reservation = assert_in_park_step(reservation)
      assert %Reservation{} = reservation = assert_external_payment_step(reservation)
      assert %Reservation{} = reservation = assert_payment2_step(reservation)

      assert {:ok, _log} =
               Logging.create_external_payment_log(%{
                 reservation_id: reservation.id,
                 body: "some body",
                 result_code: "some code",
                 received_at: DateTime.utc_now()
               })

      assert ReservationsContext.list_reservations() |> Enum.empty?() == false
      assert ReservationsContext.list_reservation_status_history() |> Enum.empty?() == false
      assert Logging.list_external_payment_logs() |> Enum.empty?() == false
      assert :ok == ReservationsContext.delete_all_reservations()
      assert ReservationsContext.list_reservations() == []
      assert ReservationsContext.list_reservation_status_history() == []
      assert Logging.list_external_payment_logs() == []
    end
  end
end
