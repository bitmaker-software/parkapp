defmodule ParkappWeb.ApiIntegration.Embers.ProductionMockTest do
  use ParkappWeb.ConnCase

  alias Parkapp.DataCase
  alias Parkapp.ReservationsContext
  alias ParkappWeb.ApiIntegration.Embers.ProductionMock
  alias Parkapp.Reservations.ReservationType.Enum, as: ReservationTypeEnum
  alias Parkapp.Reservations.ReservationType.ConfigurationStruct

  describe "EmbersProductionMock get_route" do
    @describetag :external_api_tests
    test "get_route/3 should return an {:ok, result} if successful" do
      {:ok, result} =
        ProductionMock.get_route(
          "50.93633658100821,6.976017951965332",
          "50.93633659100821,6.976017951965332",
          "CAR"
        )

      assert Map.has_key?(result, "plan")
      assert Map.has_key?(result, "requestParameters")
      plan = Map.get(result, "plan")
      assert Map.has_key?(plan, "fromPlace")
      assert Map.has_key?(plan, "toPlace")
      assert Map.has_key?(plan, "itineraries")
      itineraries = Map.get(plan, "itineraries")
      assert length(itineraries) == 1
      itineraries = List.first(itineraries)
      assert Map.has_key?(itineraries, "legs")

      legs =
        Map.get(itineraries, "legs")
        |> List.first()

      assert Map.has_key?(legs, "mode")
      assert Map.has_key?(legs, "route")
      assert Map.has_key?(legs, "instructions")
    end

    test "get_route/3 should return a nil if something goes wrong" do
      result =
        ProductionMock.get_route(
          "50.93633658100821, 6.976017951965332",
          "50.93633659100821, 6.976017951965332",
          "CAR"
        )

      assert is_nil(result)
    end

    test "get_route/3 should return an error with an unsupported geo_point" do
      {:ok, result} =
        ProductionMock.get_route(
          "40,-8",
          "41,-8",
          "CAR"
        )

      assert result == %{"error" => "There is no support for that region"}
    end

    test "get_route/3 should return an error with missing from" do
      {:error, result} =
        ProductionMock.get_route(
          "",
          "41,-8",
          "CAR"
        )

      assert result == %{"detail" => ["Needs fromPlace"]}
    end

    test "get_route/3 should return an error with missing to" do
      {:error, result} =
        ProductionMock.get_route(
          "41,-8",
          "",
          "CAR"
        )

      assert result == %{"detail" => ["Needs toPlace"]}
    end

    test "get_route/3 should return an error with missing mode" do
      {:error, result} =
        ProductionMock.get_route(
          "41,-8",
          "40,8",
          ""
        )

      assert result == %{"detail" => ["Needs Mode"]}
    end
  end

  describe "EmbersProductionMock make_reservation" do
    @config ConfigurationStruct.get_configuration(ReservationTypeEnum.single_use())
    def assert_make_reservation() do
      {:ok, result} = ProductionMock.make_reservation(@config)

      assert Map.has_key?(result, "locator")
      product = Map.get(result, "product", %{})
      assert Map.has_key?(product, "barcode")

      %{
        locator: Map.get(result, "locator"),
        barcode: Map.get(product, "barcode")
      }
    end

    test "make_reservation/1 should return an {:ok, result} if successful with single use config" do
      assert_make_reservation()
    end

    test "make_reservation/1 should return an {:ok, result} if successful with book config" do
      {:ok, result} =
        ReservationTypeEnum.booked()
        |> ConfigurationStruct.get_configuration()
        |> ProductionMock.make_reservation()

      assert Map.has_key?(result, "locator")
      product = Map.get(result, "product", %{})
      assert Map.has_key?(product, "barcode")
    end

    #
    # test "make_reservation/1 should return an {:error, result} if product type is missing" do
    #   {:error, result} = ProductionMock.make_reservation(%ConfigurationStruct{product_type: ""})
    #
    #   assert Map.get(result, "error_code") == "0xd600"
    #   assert Map.get(result, "error_message") == "Product type not valid"
    # end
    #
    # test "make_reservation/1 should return an {:error, result} with an unsupported product type" do
    #   {:error, result} =
    #     ProductionMock.make_reservation(%ConfigurationStruct{product_type: "100000"})
    #
    #   assert Map.get(result, "error_code") == "0xd600"
    #   assert Map.get(result, "error_message") == "Product type not valid"
    # end
  end

  describe "EmbersProductionMock get_reservation" do
    test "get_reservation/1 should return an {:ok, result} if successful" do
      reservation = DataCase.reservation_fixture()
      {:ok, result} = ProductionMock.get_reservation(reservation.locator)

      reservations = Map.get(result, "reservations", [])
      assert length(reservations) == 1
      current_res = List.first(reservations)
      assert Map.has_key?(current_res, "activation")
      assert Map.get(current_res, "activation") == reservation.reservation_start_time
      assert Map.has_key?(current_res, "cancelled")
      assert Map.get(current_res, "cancelled") == reservation.cancelled
      assert Map.has_key?(current_res, "expiry")
      assert Map.get(current_res, "expiry") == reservation.cancelled_at
      assert Map.has_key?(current_res, "product")
      product = Map.get(current_res, "product", %{})
      assert Map.has_key?(product, "barcode")
      assert Map.get(product, "barcode") == reservation.barcode
      assert Map.get(product, "presence_status") in [0, 1, 2, 3]
    end

    test "get_reservation/1 should return :error if locator does not exist" do
      assert :error == ProductionMock.get_reservation("")
      assert :error == ProductionMock.get_reservation("1000000")
    end
  end

  describe "EmbersProductionMock cancel_reservation" do
    test "cancel_reservation/1 should return an {:ok, result} if successful" do
      %{locator: locator, barcode: barcode} = assert_make_reservation()

      reservation = DataCase.reservation_fixture()

      assert {:ok, reservation} =
               ReservationsContext.update_reservation(reservation, %{
                 locator: locator,
                 barcode: barcode
               })

      {:ok, result} = ProductionMock.cancel_reservation(locator)

      assert Map.get(result, "locator") == locator
      assert Map.get(result, "cancelled") == true
    end

    test "cancel_reservation/1 returns nil if locator is missing" do
      result = ProductionMock.cancel_reservation("")

      assert result == :error
    end

    test "cancel_reservation/1 returns nil with an unsupported locator" do
      result = ProductionMock.cancel_reservation("1000000")

      assert result == :error
    end
  end

  describe "EmbersProductionMock delete_reservation" do
    test "delete_reservation/1 should return an {:ok, result} if successful" do
      %{locator: locator} = assert_make_reservation()
      {:ok, result} = ProductionMock.delete_reservation(locator)

      assert is_nil(result)
    end

    #
    # test "delete_reservation/1 returns nil if locator is missing" do
    #   result = ProductionMock.delete_reservation("")
    #
    #   assert is_nil(result)
    # end
    #
    # test "delete_reservation/1 returns nil with an unsupported locator" do
    #   result = ProductionMock.delete_reservation("1000000")
    #
    #   assert is_nil(result)
    # end
  end

  describe "EmbersProductionMock payment1" do
    @payment1_mock_result %{
      context_token: "some context token",
      outstanding_amount: "10.00",
      parking_payment_time: nil,
      parking_start_time: DateTime.utc_now()
    }

    def assert_payment1_result(
          %{
            "context_token" => context_token,
            "outstanding_amount" => amount,
            "parking_payment_time" => parking_payment_time,
            "parking_start_time" => parking_start_time
          },
          reservation
        ) do
      assert DateTime.diff(
               parking_start_time,
               @payment1_mock_result.parking_start_time
             ) <= 20

      assert context_token == @payment1_mock_result.context_token or
               reservation.context_token == context_token

      assert is_nil(parking_payment_time) or
               reservation.parking_payment_time == parking_payment_time

      assert amount == @payment1_mock_result.outstanding_amount or reservation.amount == amount
    end

    test "payment1/1 should always return the same result" do
      {:ok, reservation} =
        DataCase.reservation_fixture()
        |> ReservationsContext.update_reservation_after_payment1(%{
          amount: "5",
          context_token: "context token",
          payment1_time: DateTime.utc_now()
        })

      assert {:ok, result} = ProductionMock.payment1("")
      assert_payment1_result(result, reservation)

      assert {:ok, result} = ProductionMock.payment1("barcode")
      assert_payment1_result(result, reservation)

      assert {:ok, result} = ProductionMock.payment1(reservation.barcode)
      assert_payment1_result(result, reservation)
    end
  end

  describe "EmbersProductionMock payment2" do
    @payment2_mock_result :ok
    test "payment2/1 should always return the same result" do
      assert @payment2_mock_result == ProductionMock.payment2("context_token")
      assert @payment2_mock_result == ProductionMock.payment2("")
      assert @payment2_mock_result == ProductionMock.payment2(10)
      assert @payment2_mock_result == ProductionMock.payment2(nil)
    end
  end
end
