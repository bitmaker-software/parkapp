defmodule ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSyncTest do
  use Parkapp.DataCase

  alias ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSync
  alias Parkapp.ReservationsContext
  alias Parkapp.Reservations.ReservationStatus.Enum, as: ReservationStatusEnum

  describe "ReservationStateSync Test" do
    @now DateTime.utc_now()

    def assert_same_reservation(original, new) do
      original = pop_timestamps(original)
      new = pop_timestamps(new)
      assert original == new
    end

    def pop_timestamps(map) do
      {_value, map} = Map.pop(map, :inserted_at)
      {_value, map} = Map.pop(map, :updated_at)
      map
    end

    def get_default_attrs(reservation) do
      %{
        barcode: reservation.barcode,
        locator: reservation.locator,
        cancelled: reservation.cancelled,
        cancelled_at: reservation.cancelled_at,
        reservation_start_time: reservation.reservation_start_time,
        reservation_status_id: ReservationStatusEnum.open()
      }
    end

    test "get_updated_reservation/2 with :noop" do
      original_reservation = reservation_fixture()
      attrs = :noop

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert_same_reservation(original_reservation, reservation)
    end

    test "get_updated_reservation/2 with empty map" do
      original_reservation = reservation_fixture()
      attrs = %{reservation_status_id: ReservationStatusEnum.open()}

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert_same_reservation(original_reservation, reservation)
    end

    test "get_updated_reservation/2 with default open" do
      original_reservation = reservation_fixture()

      attrs =
        %{
          context_token: nil,
          amount: nil,
          payment1_time: nil,
          parking_payment_time: nil,
          parking_start_time: nil
        }
        |> Enum.into(get_default_attrs(original_reservation))

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert_same_reservation(original_reservation, reservation)
    end

    test "get_updated_reservation/2 with cancel default open" do
      original_reservation = reservation_fixture()

      attrs =
        %{
          context_token: nil,
          amount: nil,
          payment1_time: nil,
          parking_payment_time: nil,
          parking_start_time: nil,
          cancelled: true,
          cancelled_at: @now,
          reservation_status_id: ReservationStatusEnum.closed()
        }
        |> Enum.into(get_default_attrs(original_reservation))

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert reservation.cancelled
      assert reservation.cancelled_at == @now
      assert reservation.reservation_status_id == ReservationStatusEnum.closed()
    end

    test "get_updated_reservation/2 with default open from in_park" do
      original_reservation = reservation_fixture()

      assert {:ok, original_reservation} =
               ReservationsContext.move_to_in_park_state(original_reservation, @now)

      attrs =
        %{
          context_token: nil,
          amount: nil,
          payment1_time: nil,
          parking_payment_time: nil,
          parking_start_time: nil
        }
        |> Enum.into(get_default_attrs(original_reservation))

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert reservation.context_token |> is_nil()
      assert reservation.amount |> is_nil()
      assert reservation.payment1_time |> is_nil()
      assert reservation.parking_payment_time |> is_nil()
      assert reservation.parking_start_time |> is_nil()
      assert reservation.reservation_status_id == ReservationStatusEnum.open()
    end

    test "get_updated_reservation/2 with default open from payment1" do
      original_reservation = reservation_fixture()

      assert {:ok, original_reservation} =
               ReservationsContext.move_to_in_park_state(original_reservation, @now)

      assert {:ok, original_reservation} =
               ReservationsContext.update_reservation_after_payment1(original_reservation, %{
                 context_token: "some_context_token",
                 amount: "some amount",
                 payment1_time: @now
               })

      attrs =
        %{
          context_token: nil,
          amount: nil,
          payment1_time: nil,
          parking_payment_time: nil,
          parking_start_time: nil
        }
        |> Enum.into(get_default_attrs(original_reservation))

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert reservation.context_token |> is_nil()
      assert reservation.amount |> is_nil()
      assert reservation.payment1_time |> is_nil()
      assert reservation.parking_payment_time |> is_nil()
      assert reservation.parking_start_time |> is_nil()
      assert reservation.reservation_status_id == ReservationStatusEnum.open()
    end

    test "get_updated_reservation/2 with default open from payment2" do
      original_reservation = reservation_fixture()

      assert {:ok, original_reservation} =
               ReservationsContext.move_to_in_park_state(original_reservation, @now)

      assert {:ok, original_reservation} =
               ReservationsContext.update_reservation_after_payment1(original_reservation, %{
                 context_token: "some_context_token",
                 amount: "some amount",
                 payment1_time: @now
               })

      assert {:ok, original_reservation} =
               ReservationsContext.update_reservation_after_payment2(original_reservation, %{
                 parking_payment_time: @now
               })

      attrs =
        %{
          context_token: nil,
          amount: nil,
          payment1_time: nil,
          parking_payment_time: nil,
          parking_start_time: nil
        }
        |> Enum.into(get_default_attrs(original_reservation))

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert reservation.context_token |> is_nil()
      assert reservation.amount |> is_nil()
      assert reservation.payment1_time |> is_nil()
      assert reservation.parking_payment_time |> is_nil()
      assert reservation.parking_start_time |> is_nil()
      assert reservation.reservation_status_id == ReservationStatusEnum.open()
    end

    test "get_updated_reservation/2 with timmed out open / closed" do
      original_reservation = reservation_fixture()

      attrs =
        %{reservation_status_id: ReservationStatusEnum.closed()}
        |> Enum.into(get_default_attrs(original_reservation))

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert reservation.reservation_status_id == ReservationStatusEnum.closed()
    end

    test "get_updated_reservation/2 with payed inpark" do
      original_reservation = reservation_fixture()

      attrs =
        %{
          context_token: "context_token",
          amount: "amount",
          parking_start_time: @now,
          parking_payment_time: @now,
          payment1_time: @now,
          reservation_status_id: ReservationStatusEnum.payment2()
        }
        |> Enum.into(get_default_attrs(original_reservation))

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert reservation.reservation_status_id == ReservationStatusEnum.payment2()
      assert reservation.context_token == "context_token"
      assert reservation.amount == "amount"
      assert reservation.parking_start_time == @now
      assert reservation.parking_payment_time == @now
    end

    test "get_updated_reservation/2 with default inpark" do
      original_reservation = reservation_fixture()

      attrs =
        %{
          parking_payment_time: nil,
          parking_start_time: @now,
          reservation_status_id: ReservationStatusEnum.in_park()
        }
        |> Enum.into(get_default_attrs(original_reservation))

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert reservation.reservation_status_id == ReservationStatusEnum.in_park()
      assert reservation.parking_start_time == @now
      assert reservation.parking_payment_time |> is_nil()
    end

    test "get_updated_reservation/2 with timmed out inpark" do
      original_reservation = reservation_fixture()

      attrs =
        %{
          context_token: nil,
          amount: nil,
          payment1_time: nil,
          parking_payment_time: nil,
          parking_start_time: @now,
          reservation_status_id: ReservationStatusEnum.in_park()
        }
        |> Enum.into(get_default_attrs(original_reservation))

      assert {:ok, reservation} =
               ReservationStateSync.get_updated_reservation(original_reservation, attrs)

      assert reservation.reservation_status_id == ReservationStatusEnum.in_park()
      assert reservation.parking_start_time == @now
      assert reservation.parking_payment_time |> is_nil()
      assert reservation.context_token |> is_nil()
      assert reservation.amount |> is_nil()
      assert reservation.payment1_time |> is_nil()
    end
  end
end
