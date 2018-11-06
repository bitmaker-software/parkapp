defmodule ParkappWeb.ApiIntegration.MBWay.WebhookDataTest do
  use Parkapp.DataCase

  alias ParkappWeb.ApiIntegration.MBWay.WebhookData

  describe "MBWay WebhookData" do
    @invalid_body %{}
    @result_code "some code"
    @device_id "some device"
    @valid_body %{
      "type" => "PAYMENT",
      "payload" => %{
        "id" => "8a829449515d198b01517d5601df5584",
        "paymentType" => "DB",
        "paymentBrand" => "MBWAY",
        "amount" => "10.00",
        "currency" => "EUR",
        "descriptor" => "3017.7139.1650 OPP_Channel ",
        "merchantTransactionId" => "some id",
        "result" => %{
          "code" => @result_code,
          "description" => "Request successfully processed in 'Merchant in Integrator Test Mode'"
        },
        "authentication" => %{
          "entityId" => "8a8294185282b95b01528382b4940245"
        },
        "customParameters" => %{
          "device_id" => @device_id
        },
        "risk" => %{
          "score" => "0"
        },
        "timestamp" => "2015-12-07 16:46:07+0000",
        "ndc" => "8a8294174b7ecb28014b9699220015ca_66b12f658442479c8ca66166c4999e78",
        "virtualAccount" => %{
          "accountId" => "351#911222111"
        }
      }
    }

    test "build/1 should return nil if the body is invalid" do
      assert WebhookData.build(@invalid_body) |> is_nil()
    end

    test "build/1 should return WebhookData if the body is valid" do
      assert WebhookData.build(@valid_body) == %WebhookData{
               result_code: @result_code,
               device_id: @device_id,
               body: Poison.encode!(@valid_body)
             }
    end

    test "validate/1 should return true if the payment was successfull 1" do
      assert WebhookData.validate(%WebhookData{
               result_code: "000.000.000"
             })
    end

    test "validate/1 should return true if the payment was successfull 2" do
      assert WebhookData.validate(%WebhookData{
               result_code: "000.100.110"
             })
    end

    test "validate/1 should return false if the payment was not successfull" do
      assert WebhookData.validate(%WebhookData{
               result_code: "800.400.500"
             }) == false
    end

    test "should_revert/1 should return true if the payment was not successfull 1" do
      assert WebhookData.should_revert(%WebhookData{
               result_code: "000.000.000"
             })
    end

    test "should_revert/1 should return true if the payment was not successfull 2" do
      assert WebhookData.should_revert(%WebhookData{
               result_code: "000.100.110"
             })
    end

    test "should_revert/1 should return true if the payment was not successfull 3" do
      assert WebhookData.should_revert(%WebhookData{
               result_code: "800.100.110"
             })
    end

    test "should_revert/1 should return false if the result code is indifferent" do
      assert WebhookData.should_revert(%WebhookData{
               result_code: "800.400.500"
             }) == false
    end
  end
end
