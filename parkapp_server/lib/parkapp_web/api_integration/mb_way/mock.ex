defmodule ParkappWeb.ApiIntegration.MBWay.Mock do
  @moduledoc """
    Mock implementation of the MBWay API. Used for testing.
  """

  @behaviour ParkappWeb.ApiIntegration.MBWay.Behaviour

  def request_payment(_user_token, _phone_number, _amount) do
    {:ok,
     %{
       "amount" => "10.00",
       "buildNumber" => "f7c953080e1b6da8cfcf6cb8ca1a460db91503a6@2018-09-11 12:23:05 +0000",
       "currency" => "EUR",
       "descriptor" => "4351.8240.8354",
       "id" => "8a82944965d7d50b0165ebee15350fe1",
       "merchantTransactionId" => "user token",
       "ndc" => "8a8294185bd901c5015be855fd5f1578_94ac23ff79f141a3969ae480fb6b9b91",
       "paymentBrand" => "MBWAY",
       "paymentType" => "DB",
       "result" => %{
         "code" => "800.400.500",
         "description" => "Waiting for confirmation of non-instant payment. Denied for now."
       },
       "resultDetails" => %{
         "AcquirerResponse" => "Pending",
         "ConnectorTxID1" => "4351.8240.8354",
         "ConnectorTxID2" => "2018-09-18 09:06:13",
         "ConnectorTxID3" => "S08058100624238S||351#911222111|MobilePhone|",
         "Pre-authorization validity" => "2018-09-15T01:00:00.001+01:00"
       },
       "timestamp" => "2018-09-18 09:06:14+0000"
     }}
  end
end
