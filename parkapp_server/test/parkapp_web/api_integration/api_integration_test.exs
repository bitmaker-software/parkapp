defmodule ParkappWeb.ApiIntegrationTest do
  use ParkappWeb.ConnCase

  alias ParkappWeb.ApiIntegration
  alias ParkappWeb.ApiIntegration.Helpers
  alias ParkappWeb.ApiIntegration.MBWay.WebhookData
  alias Parkapp.DataCase

  alias Parkapp.Reservations.{
    Reservation,
    ReservationStatus,
    ReservationType
  }

  alias Parkapp.ReservationsContext

  describe "ApiIntegration Test" do
    alias Parkapp.Logging
    alias Parkapp.Logging.ExternalPaymentLog

    @now DateTime.utc_now()

    def assert_reservation_step1() do
      device = DataCase.device_fixture()

      assert {:ok, %Reservation{} = reservation} =
               ApiIntegration.reserve_single_use(device.device_id)

      assert reservation.device_id == device.device_id
      assert reservation.reservation_status_id == ReservationStatus.Enum.open()
      assert reservation.barcode == "some barcode"
      assert reservation.locator == "some locator"
      assert reservation.reservation_type_id == ReservationType.Enum.single_use()

      reservation
    end

    def assert_book_step1() do
      device = DataCase.device_fixture()

      assert {:ok, %Reservation{} = reservation} =
               ApiIntegration.book_reservation(device.device_id)

      assert reservation.device_id == device.device_id
      assert reservation.reservation_status_id == ReservationStatus.Enum.open()
      assert reservation.barcode == "some barcode"
      assert reservation.locator == "some locator"
      assert reservation.reservation_type_id == ReservationType.Enum.booked()

      reservation
    end

    def assert_reservation_payment1(%Reservation{} = reservation) do
      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()

      assert {:ok, %Reservation{} = reservation} = ApiIntegration.payment1(reservation.device_id)

      assert reservation.context_token == "some context token"
      assert reservation.amount == "10.00"
      assert reservation.payment1_time |> is_nil() == false
      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()

      reservation
    end

    def assert_reservation_step2() do
      assert %Reservation{} = reservation = assert_reservation_step1()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.move_to_in_park_state(reservation, @now)

      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()
      assert reservation.parking_start_time == @now
      reservation = assert_reservation_payment1(reservation)
      assert {:ok, %Reservation{} = reservation} = ApiIntegration.pay(reservation.device_id, "")

      reservation
    end

    def get_timeout_string(reservation) do
      Timex.add(
        reservation.cancelled_at,
        Timex.Duration.from_seconds(Helpers.get_value_from_config(:cancel_reservation_ban_time))
      )
      |> Timex.format!("%Y-%m-%d %H:%M:%S", :strftime)
    end

    test "reserve_single_use/1 should return an {:ok, reservation} if successful" do
      assert %Reservation{} = _reservation = assert_reservation_step1()
    end

    test "reserve_single_use/1 should return an {:timeout, unban_at} if the device is banned" do
      assert %Reservation{} = reservation = assert_reservation_step1()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.cancel_reservation(reservation)

      assert {:timeout, get_timeout_string(reservation)} ==
               ApiIntegration.reserve_single_use(reservation.device_id)
    end

    test "reserve_single_use/1 should return an nil if there is already a reservation for the given device" do
      assert %Reservation{} = reservation = assert_reservation_step1()
      assert ApiIntegration.reserve_single_use(reservation.device_id) |> is_nil()
    end

    test "reserve_single_use/1 should return an error if the device_id does not exist" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               ApiIntegration.reserve_single_use(Ecto.UUID.generate())

      assert DataCase.errors_on(changeset) == %{
               device_id: ["does not exist"]
             }
    end

    test "book_reservation/1 should return an {:ok, reservation} if successful" do
      assert %Reservation{} = _reservation = assert_book_step1()
    end

    test "book_reservation/1 should return an {:timeout, unban_at} if device is banned" do
      assert %Reservation{} = reservation = assert_book_step1()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.cancel_reservation(reservation)

      assert {:timeout, get_timeout_string(reservation)} ==
               ApiIntegration.book_reservation(reservation.device_id)
    end

    test "book_reservation/1 should return an nil if there is already a reservation for the given device" do
      assert %Reservation{} = reservation = assert_book_step1()
      assert ApiIntegration.book_reservation(reservation.device_id) |> is_nil()
    end

    test "book_reservation/1 should return an error if the device_id does not exist" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               ApiIntegration.book_reservation(Ecto.UUID.generate())

      assert DataCase.errors_on(changeset) == %{
               device_id: ["does not exist"]
             }
    end

    test "cancel_reservation/1 should return an {:ok, reservation} if successful" do
      assert %Reservation{} = reservation = assert_reservation_step1()
      assert reservation.reservation_status_id == ReservationStatus.Enum.open()

      assert {:ok, %Reservation{} = reservation} =
               ApiIntegration.cancel_reservation(reservation.device_id)

      assert reservation.reservation_status_id == ReservationStatus.Enum.closed()
    end

    test "pay/2 should return an {:ok, reservation} if successful" do
      assert %Reservation{} = reservation = assert_reservation_step2()
      assert reservation.reservation_status_id == ReservationStatus.Enum.external_payment()
      assert reservation.context_token == "some context token"
      assert reservation.amount == "10.00"
    end

    test "pay/2 should return an :timeout if user took too long to pay" do
      assert %Reservation{} = reservation = assert_reservation_step1()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.move_to_in_park_state(reservation, @now)

      assert %Reservation{} = reservation = assert_reservation_payment1(reservation)

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.update_reservation_after_payment1(reservation, %{
                 payment1_time:
                   Timex.subtract(
                     reservation.payment1_time,
                     Timex.Duration.from_seconds(Helpers.get_value_from_config(:time_to_pay) + 1)
                   )
               })

      assert :timeout == ApiIntegration.pay(reservation.device_id, "phone number")
    end

    test "payment1/1 should return an {:ok, reservation} if successful" do
      assert %Reservation{} = reservation = assert_reservation_step1()

      assert {:ok, %Reservation{} = reservation} =
               ReservationsContext.move_to_in_park_state(reservation, @now)

      assert_reservation_payment1(reservation)
    end

    test "pay/2 should return nil if there are problems" do
      assert %Reservation{} = reservation = assert_reservation_step1()
      assert ApiIntegration.pay(reservation.device_id, "") |> is_nil()
      assert ApiIntegration.pay(Ecto.UUID.generate(), "") |> is_nil()
      assert ApiIntegration.pay(Ecto.UUID.generate(), "123") |> is_nil()
    end

    @body "{\"type\":\"PAYMENT\",\"payload\":{\"virtualAccount\":{\"accountId\":\"351#911222111\"},\"timestamp\":\"2018-10-15 16:26:37+0000\",\"risk\":{\"score\":\"\"},\"resultDetails\":{\"Pre-authorization validity\":\"2018-09-15T01:00:00.001+01:00\",\"ConnectorTxID3\":\"68b22f0166788ce7355c6b\",\"ConnectorTxID2\":\"8ac7a4a2\",\"ConnectorTxID1\":\"8ac7a4a26668b22f0166788ce7355c6b\",\"AcquirerResponse\":\"APPR\"},\"result\":{\"randomField58084894\":\"Please allow for new unexpected fields to be added\",\"description\":\"Request successfully processed in 'Merchant in Integrator Test Mode'\",\"code\":\"000.100.110\"},\"redirect\":{\"parameters\":[]},\"presentationCurrency\":\"EUR\",\"presentationAmount\":\"10.0\",\"paymentType\":\"DB\",\"paymentBrand\":\"MBWAY\",\"ndc\":\"8a8294185bd901c5015be855fd5f1578_2d1fa62fb82a42dea7659cc7923a5f73\",\"merchantTransactionId\":\"some id\",\"id\":\"8ac7a4a26668b22f0166788ce7355c6b\",\"descriptor\":\"5727.6653.0069\",\"customParameters\":{\"device_id\":\"a2ffa2d8-d656-4068-b67a-911e1420cf14\"},\"currency\":\"EUR\",\"authentication\":{\"entityId\":\"8a8294185bd901c5015be855fd5f1578\"},\"amount\":\"10.0\"}}"

    test "complete_payment_procedure/2 should return an {:ok, reservation} if successful" do
      assert %Reservation{} = reservation = assert_reservation_step2()

      assert reservation.reservation_status_id == ReservationStatus.Enum.external_payment()

      assert {:ok, %Reservation{} = reservation} =
               ApiIntegration.complete_payment_procedure(%WebhookData{
                 result_code: "000.100.110",
                 device_id: reservation.device_id,
                 body: @body
               })

      assert reservation.reservation_status_id == ReservationStatus.Enum.payment2()

      list_of_logs = Logging.list_external_payment_logs(reservation.id)
      assert length(list_of_logs) == 1
      assert %ExternalPaymentLog{} = external_log = List.first(list_of_logs)
      assert external_log.body == @body
      assert external_log.result_code == "000.100.110"
    end

    test "complete_payment_procedure/2 should revert the reservation to inpark status if the data is not valid" do
      assert %Reservation{} = reservation = assert_reservation_step2()

      assert reservation.reservation_status_id == ReservationStatus.Enum.external_payment()
      assert !is_nil(reservation.amount)
      assert !is_nil(reservation.payment1_time)
      assert !is_nil(reservation.context_token)

      assert {:ok, %Reservation{} = reservation} =
               ApiIntegration.complete_payment_procedure(%WebhookData{
                 result_code: "800.100.110",
                 device_id: reservation.device_id,
                 body: "some params"
               })

      assert reservation.reservation_status_id == ReservationStatus.Enum.in_park()
      assert is_nil(reservation.amount)
      assert is_nil(reservation.payment1_time)
      assert is_nil(reservation.context_token)

      list_of_logs = Logging.list_external_payment_logs(reservation.id)
      assert length(list_of_logs) == 1
      assert %ExternalPaymentLog{} = external_log = List.first(list_of_logs)
      assert external_log.body == "some params"
      assert external_log.result_code == "800.100.110"
    end

    test "complete_payment_procedure/2 should return nil if there are problems" do
      assert %Reservation{} = assert_reservation_step1()
      assert ApiIntegration.complete_payment_procedure(nil) |> is_nil()
    end
  end
end
