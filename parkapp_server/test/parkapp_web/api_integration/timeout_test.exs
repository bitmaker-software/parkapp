defmodule ParkappWeb.ApiIntegration.TimeoutTest do
  use Parkapp.DataCase

  alias ParkappWeb.ApiIntegration.{Timeout, Helpers}

  alias Parkapp.Reservations.{
    Reservation,
    ReservationStatus
  }

  alias Parkapp.ReservationsContext

  describe "Timeout Test" do
    @reservation_start_time :reservation_start_time
    @payment1_time :payment1_time
    @cancelled_at :cancelled_at
    @default_delay 1000

    def assert_open_reservation() do
      assert %Reservation{} = reservation = reservation_fixture()
      assert reservation.reservation_status_id == ReservationStatus.Enum.open()
      reservation
    end

    def assert_payment1_reservation() do
      assert %Reservation{} = reservation = assert_open_reservation()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.move_to_in_park_state(reservation, DateTime.utc_now())

      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.update_reservation_after_payment1(reservation, %{
                 context_token: "some context token",
                 amount: "some amount",
                 payment1_time: DateTime.utc_now()
               })

      reservation
    end

    def delay_reservation(reservation, field, delay \\ @default_delay) do
      new_time =
        Map.get(reservation, field)
        |> Timex.subtract(Timex.Duration.from_seconds(delay))

      attrs = Map.put_new(%{}, field, new_time)

      cond do
        field == @payment1_time ->
          attrs =
            Map.put(attrs, :context_token, "some context token")
            |> Map.put(:amount, "some amount")

          assert {:ok, reservation} =
                   ReservationsContext.update_reservation_after_payment1(reservation, attrs)

          reservation

        field in [@reservation_start_time, @cancelled_at] ->
          assert {:ok, reservation} = ReservationsContext.update_reservation(reservation, attrs)
          reservation

        true ->
          nil
      end
    end

    test "check_time_to_enter_park_timeout/1 should return false if not enough time has past" do
      assert %Reservation{} = reservation = assert_open_reservation()
      assert Timeout.check_time_to_enter_park_timeout(reservation) == false
    end

    test "check_time_to_enter_park_timeout/1 should return true if enough time has past" do
      assert %Reservation{} = reservation = assert_open_reservation()

      assert %Reservation{} =
               reservation = delay_reservation(reservation, @reservation_start_time)

      assert Timeout.check_time_to_enter_park_timeout(reservation)
    end

    test "check_time_to_enter_park_after_booking_timeout/1 should return false if not enough time has past" do
      assert %Reservation{} = reservation = assert_open_reservation()
      assert Timeout.check_time_to_enter_park_after_booking_timeout(reservation) == false
    end

    test "check_time_to_enter_park_after_booking_timeout/1 should return true if enough time has past" do
      assert %Reservation{} = reservation = assert_open_reservation()

      assert %Reservation{} =
               reservation = delay_reservation(reservation, @reservation_start_time, 2000)

      assert Timeout.check_time_to_enter_park_after_booking_timeout(reservation)
    end

    test "check_time_to_pay_timeout/1 should return false if not enough time has past" do
      assert %Reservation{} = reservation = assert_payment1_reservation()
      assert Timeout.check_time_to_pay_timeout(reservation) == false
    end

    test "check_time_to_pay_timeout/1 should return true if enough time has past" do
      assert %Reservation{} = reservation = assert_payment1_reservation()
      assert %Reservation{} = reservation = delay_reservation(reservation, @payment1_time)
      assert Timeout.check_time_to_pay_timeout(reservation)
    end

    test "check_time_since_last_cancelled_reservation/1 should return false if not enough time has past" do
      assert %Reservation{} = reservation = assert_payment1_reservation()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.cancel_reservation(reservation)

      assert Timeout.check_time_since_last_cancelled_reservation(reservation.device_id) == false
    end

    test "check_time_since_last_cancelled_reservation/1 should return true if there are not cancelled reservations" do
      assert %Reservation{} = reservation = assert_payment1_reservation()
      assert Timeout.check_time_since_last_cancelled_reservation(reservation.device_id) == true
    end

    test "check_time_since_last_cancelled_reservation/1 should return true if there are no reservations for the device" do
      device = device_fixture()
      assert Timeout.check_time_since_last_cancelled_reservation(device.device_id) == true
    end

    test "check_time_since_last_cancelled_reservation/1 should return true if enough time has past" do
      assert %Reservation{} = reservation = assert_payment1_reservation()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.cancel_reservation(reservation)

      assert %Reservation{} = reservation = delay_reservation(reservation, @cancelled_at)
      assert Timeout.check_time_since_last_cancelled_reservation(reservation.device_id) == true
    end

    test "get_unban_datetime/1 should return DateTime of the unban moment if not enough time has past" do
      assert %Reservation{} = reservation = assert_payment1_reservation()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.cancel_reservation(reservation)

      assert Timeout.get_unban_datetime(reservation.device_id) ==
               Timex.add(
                 reservation.cancelled_at,
                 Timex.Duration.from_seconds(
                   Helpers.get_value_from_config(:cancel_reservation_ban_time)
                 )
               )
               |> Timex.format!("%Y-%m-%d %H:%M:%S", :strftime)
    end

    test "get_unban_datetime/1 should return nil if there are not cancelled reservations" do
      assert %Reservation{} = reservation = assert_payment1_reservation()
      assert Timeout.get_unban_datetime(reservation.device_id) |> is_nil()
    end

    test "get_unban_datetime/1 should return nil if there are no reservations for the device" do
      device = device_fixture()
      assert Timeout.get_unban_datetime(device.device_id) |> is_nil()
    end

    test "get_unban_datetime/1 should return nil if enough time has past" do
      assert %Reservation{} = reservation = assert_payment1_reservation()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.cancel_reservation(reservation)

      assert %Reservation{} = reservation = delay_reservation(reservation, @cancelled_at)
      assert Timeout.get_unban_datetime(reservation.device_id) |> is_nil()
    end
  end
end
