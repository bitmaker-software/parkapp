defmodule ParkappWeb.ApiIntegration.MBWay.APITest do
  use ParkappWeb.ConnCase

  @moduletag :external_api_tests

  alias ParkappWeb.ApiIntegration.MBWay.API

  @merchantTransactionId "some id"

  describe "MBWayAPI request_payment/3" do
    test "request_payment/3 should return an {:ok, result} if successful" do
      device_id = Parkapp.DataCase.device_fixture().device_id

      {:ok, result} =
        API.request_payment(
          device_id,
          "351#911222111",
          "10.00"
        )

      assert Map.get(result, "amount") == "10.00"
      assert Map.has_key?(result, "id")
      assert Map.get(result, "merchantTransactionId") == @merchantTransactionId
      assert Map.get(result, "result", %{}) |> Map.get("code") == "800.400.500"

      assert Map.get(result, "result", %{})
             |> Map.get("description")
             |> String.contains?("Denied for now")

      assert Map.get(result, "resultDetails", %{})
             |> Map.get("ConnectorTxID3")
             |> String.contains?("351#911222111")

      assert Map.get(result, "customParameters", %{}) |> Map.get("device_id") == device_id
    end

    test "request_payment/3 does not require a user token" do
      {:ok, result} =
        API.request_payment(
          "",
          "351#911222111",
          "10.00"
        )

      assert Map.get(result, "amount") == "10.00"
      assert Map.has_key?(result, "id")
      assert Map.get(result, "merchantTransactionId") == @merchantTransactionId
      assert Map.get(result, "result", %{}) |> Map.get("code") == "800.400.500"

      assert Map.get(result, "result", %{})
             |> Map.get("description")
             |> String.contains?("Denied for now")

      assert Map.get(result, "resultDetails", %{})
             |> Map.get("ConnectorTxID3")
             |> String.contains?("351#911222111")

      assert Map.has_key?(result, "customParameters") == false
    end

    test "request_payment/3 should return an {:error, result} if phone number is missing" do
      {:error, result} =
        API.request_payment(
          "user token",
          "",
          "10.00"
        )

      assert Map.get(result, "amount") == "10.00"
      assert Map.has_key?(result, "id")
      assert Map.get(result, "merchantTransactionId") == @merchantTransactionId
      assert Map.get(result, "result", %{}) |> Map.get("code") == "200.100.103"

      assert Map.get(result, "result", %{})
             |> Map.get("description")
             |> String.contains?("invalid Request Message")

      assert Map.get(result, "resultDetails", %{})
             |> Map.get("AcquirerResponse")
             |> String.contains?("ID is missing")
    end

    test "request_payment/3 should return an {:error, result} if amount is missing" do
      {:error, result} =
        API.request_payment(
          "user token",
          "351#911222111",
          ""
        )

      assert Map.get(result, "result", %{}) |> Map.get("code") == "200.300.404"

      assert Map.get(result, "result", %{})
             |> Map.get("description") == "invalid or missing parameter"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("name") == "amount"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("message") == "may not be empty"
    end

    test "request_payment/3 should return an {:error, result} if amount has invalid format 1" do
      {:error, result} =
        API.request_payment(
          "user token",
          "351#911222111",
          "10,00"
        )

      assert Map.get(result, "result", %{}) |> Map.get("code") == "200.300.404"

      assert Map.get(result, "result", %{})
             |> Map.get("description") == "invalid or missing parameter"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("name") == "amount"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("message")
             |> String.contains?("must match")
    end

    test "request_payment/3 should return an {:error, result} if amount has invalid format 2" do
      {:error, result} =
        API.request_payment(
          "user token",
          "351#911222111",
          "10. 00"
        )

      assert Map.get(result, "result", %{}) |> Map.get("code") == "200.300.404"

      assert Map.get(result, "result", %{})
             |> Map.get("description") == "invalid or missing parameter"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("name") == "amount"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("message")
             |> String.contains?("must match")
    end

    test "request_payment/3 should return an {:error, result} if amount has invalid format 3" do
      {:error, result} =
        API.request_payment(
          "user token",
          "351#911222111",
          "amount"
        )

      assert Map.get(result, "result", %{}) |> Map.get("code") == "200.300.404"

      assert Map.get(result, "result", %{})
             |> Map.get("description") == "invalid or missing parameter"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("name") == "amount"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("message")
             |> String.contains?("must match")
    end

    test "request_payment/3 should return an {:error, result} if params are missing" do
      {:error, result} =
        API.request_payment(
          "",
          "",
          ""
        )

      assert Map.get(result, "result", %{}) |> Map.get("code") == "200.300.404"

      assert Map.get(result, "result", %{})
             |> Map.get("description") == "invalid or missing parameter"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("name") == "amount"

      assert Map.get(result, "result", %{})
             |> Map.get("parameterErrors", [])
             |> List.first()
             |> Map.get("message") == "may not be empty"
    end
  end
end
