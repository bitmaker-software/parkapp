defmodule ParkappWeb.ApiIntegration.Embers.APITest do
  use ParkappWeb.ConnCase

  @moduletag :external_api_tests

  alias ParkappWeb.ApiIntegration.Embers.API
  alias Parkapp.Reservations.ReservationType.Enum, as: ReservationTypeEnum
  alias Parkapp.Reservations.ReservationType.ConfigurationStruct

  describe "EmbersAPI get_route" do
    test "get_route/3 should return an {:ok, result} if successful" do
      {:ok, result} =
        API.get_route(
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
        API.get_route(
          "50.93633658100821, 6.976017951965332",
          "50.93633659100821, 6.976017951965332",
          "CAR"
        )

      assert is_nil(result)
    end

    test "get_route/3 should return an error with an unsupported geo_point" do
      {:ok, result} =
        API.get_route(
          "40,-8",
          "41,-8",
          "CAR"
        )

      assert result == %{"error" => "There is no support for that region"}
    end

    test "get_route/3 should return an error with missing from" do
      {:error, result} =
        API.get_route(
          "",
          "41,-8",
          "CAR"
        )

      assert result == %{"detail" => ["Needs fromPlace"]}
    end

    test "get_route/3 should return an error with missing to" do
      {:error, result} =
        API.get_route(
          "41,-8",
          "",
          "CAR"
        )

      assert result == %{"detail" => ["Needs toPlace"]}
    end

    test "get_route/3 should return an error with missing mode" do
      {:error, result} =
        API.get_route(
          "41,-8",
          "40,8",
          ""
        )

      assert result == %{"detail" => ["Needs Mode"]}
    end
  end

  describe "EmbersAPI make_reservation" do
    @config ConfigurationStruct.get_configuration(ReservationTypeEnum.single_use())
    def assert_make_reservation() do
      {:ok, result} = API.make_reservation(@config)

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
        |> API.make_reservation()

      assert Map.has_key?(result, "locator")
      product = Map.get(result, "product", %{})
      assert Map.has_key?(product, "barcode")
    end

    test "make_reservation/1 should return an {:error, result} if product type is missing" do
      {:error, result} = API.make_reservation(%ConfigurationStruct{product_type: ""})

      assert Map.get(result, "error_code") == "0xd600"
      assert Map.get(result, "error_message") == "Product type not valid"
    end

    test "make_reservation/1 should return an {:error, result} with an unsupported product type" do
      {:error, result} = API.make_reservation(%ConfigurationStruct{product_type: "100000"})

      assert Map.get(result, "error_code") == "0xd600"
      assert Map.get(result, "error_message") == "Product type not valid"
    end
  end

  describe "EmbersAPI get_reservation" do
    test "get_reservation/1 should return an {:ok, result} if successful" do
      %{locator: locator} = assert_make_reservation()
      {:ok, result} = API.get_reservation(locator)

      reservations = Map.get(result, "reservations", [])
      assert length(reservations) == 1
      current_res = List.first(reservations)
      assert Map.has_key?(current_res, "activation")
      assert Map.has_key?(current_res, "cancelled")
      assert Map.has_key?(current_res, "locator")
      assert Map.get(current_res, "locator", "") == locator
      assert Map.has_key?(current_res, "product")
      product = Map.get(current_res, "product", %{})
      assert Map.has_key?(product, "barcode")
      assert Map.has_key?(product, "number")
      assert Map.get(product, "presence_status") in [0, 1, 2, 3]
    end

    test "get_reservation/1 should return a all reservations if locator is missing" do
      {:ok, result} = API.get_reservation("")

      reservations = Map.get(result, "reservations", [])
      assert length(reservations) > 1
    end

    test "get_reservation/1 should return an empty list with a non existing locator" do
      {:ok, result} = API.get_reservation("1000000")

      assert result == %{"reservations" => []}
    end
  end

  describe "EmbersAPI cancel_reservation" do
    test "cancel_reservation/1 should return an {:ok, result} if successful" do
      %{locator: locator} = assert_make_reservation()
      {:ok, result} = API.cancel_reservation(locator)

      assert Map.get(result, "locator") == locator
      assert Map.get(result, "cancelled") == true
    end

    test "cancel_reservation/1 returns nil if locator is missing" do
      result = API.cancel_reservation("")

      assert is_nil(result)
    end

    test "cancel_reservation/1 returns nil with an unsupported locator" do
      result = API.cancel_reservation("1000000")

      assert is_nil(result)
    end
  end

  describe "EmbersAPI delete_reservation" do
    test "delete_reservation/1 should return an {:ok, result} if successful" do
      %{locator: locator} = assert_make_reservation()
      {:ok, result} = API.delete_reservation(locator)

      assert is_nil(result)
    end

    test "delete_reservation/1 returns nil if locator is missing" do
      result = API.delete_reservation("")

      assert is_nil(result)
    end

    test "delete_reservation/1 returns nil with an unsupported locator" do
      result = API.delete_reservation("1000000")

      assert is_nil(result)
    end
  end

  #   describe "asdajkdka" do
  #     test "afefewf" do
  #       {_domain, api_key, _} = Helpers.get_config(:trindade_park)
  #
  #       barcode = "Q4855193809887089219701161680090523"
  # # curl -X POST -H 'Authorization: Basic c2FnYV9yZXN0X2FwaTplcXByaw==' -i 'http://tunel.equinsaparking.com:10001/rest_api/products/barcode/Q4855193809887089219701161680090523/payment1'
  #       url = "http://tunel.equinsaparking.com:10190/rest_api/products/barcode/#{barcode}/payment1"
  #
  #       result =
  #         HTTPoison.get(
  #           url,
  #           "X-Gravitee-Api-Key": api_key
  #         )
  #
  #       assert result == ""
  #     end
  #   end
  #
  #   describe "EmbersAPI payment1" do
  #     def assert_payment1() do
  #       %{barcode: barcode} = assert_make_reservation()
  #       IO.inspect(barcode, label: "ajksd")
  # Timex.now("Europe/Berlin")
  # |> Helpers.format_date_time()
  # |> IO.inspect(label: "now")
  #       {:ok, result} = API.payment1(barcode)
  #
  #       assert result == ""
  #
  #       Map.get(result, "context_token")
  #     end
  #
  #     test "payment1/1 should return an {:ok, result} if successful" do
  #       assert_payment1()
  #     end
  #
  #     test "payment1/1 returns nil if barcode is missing" do
  #       result = API.payment1("")
  #
  #       assert is_nil(result)
  #     end
  #
  #     test "payment1/1 returns nil with an unsupported barcode" do
  #       result = API.payment1("1000000")
  #
  #       assert is_nil(result)
  #     end
  #   end

  #
  # describe "EmbersAPI payment2" do
  #   test "payment2/1 should return an {:ok, result} if successful" do
  #     context_token = assert_payment1()
  #
  #     {:ok, result} = API.payment2(context_token)
  #
  #     assert result == ""
  #   end
  #
  #   test "payment2/1 returns nil if context_token is missing" do
  #     result = API.payment2("")
  #
  #     assert is_nil(result)
  #   end
  #
  #   test "payment2/1 returns nil with an unsupported context_token" do
  #     result = API.payment2("1000000")
  #
  #     assert is_nil(result)
  #   end
  # end
end
