defmodule ParkappWeb.ApiIntegration.MBWay.API do
  @moduledoc """
    Main implementation of the MBWay API.
  """

  @behaviour ParkappWeb.ApiIntegration.MBWay.Behaviour
  import ParkappWeb.ApiIntegration.MBWay.Helpers

  @doc """
    Makes a post request to the SIBS API to perform an MBWay one-shot payment
  """
  def request_payment(user_token, phone_number, amount) do
    {domain, user_id, entity_id, password, payment_brand, currency, payment_type} = get_config()

    url = "#{domain}/payments"

    HTTPoison.post(
      url,
      {:form,
       [
         "authentication.userId": user_id,
         "authentication.entityId": entity_id,
         "authentication.password": password,
         currency: currency,
         paymentType: payment_type,
         paymentBrand: payment_brand,
         amount: amount,
         # need to validate? mbway accepts anything here because it is not used right away.
         "virtualAccount.accountId": phone_number,
         # Merchant-provided reference number, should be unique for your transactions. Some receivers require this ID. This identifier is often used for reconciliation.
         merchantTransactionId: "some id",
         # Device_id or Reservation_id or locator?
         "customParameters['device_id']": user_token,
         descriptor: ""
       ]}
    )
    |> handle_http_response()
  end
end

# Para poderem simular os pagamentos mbway podem usar
#
# POST para https://test.onlinepayments.pt/v1/payments com
#
# authentication.userId=8a8294185b674555015b7c1928e81736
# authentication.entityId=8a8294185bd901c5015be855fd5f1578
# authentication.password=Rr47eQesdW
# amount=10.00
# currency=EUR
# paymentType=DB
# paymentBrand=MBWAY
# virtualAccount.accountId=351#911222111

# webhook should be like this:
# %{
#   "type" => "PAYMENT",
#   "action" => "CREATED" or "UPDATED",
#   "payload" => %{
#     "referencedId", "paymentBrand", "amount", "currency", "descriptor", "result.code", "result.description"
#   }
# }
# {"encryptedBody":"[(encrypted) hexadecimal string]"}
# check crypto function
# {
#    "type":"PAYMENT",
#    "payload":{
#       "id":"8a829449515d198b01517d5601df5584",#gravar nos logs
#       "paymentType":"PA",
#       "paymentBrand":"VISA",
#       "amount":"92.00",
#       "currency":"EUR",
#       "presentationAmount":"92.00",
#       "presentationCurrency":"EUR",
#       "descriptor":"3017.7139.1650 OPP_Channel ",
#       "result":{
#          "code":"000.100.110",#que codes devemos suportar?
#          "description":"Request successfully processed in 'Merchant in Integrator Test Mode'"
#       },
#       "authentication":{
#          "entityId":"8a8294185282b95b01528382b4940245"
#       },
#       "card":{
#          "bin":"420000",
#          "last4Digits":"0000",
#          "holder":"Jane Jones",
#          "expiryMonth":"05",
#          "expiryYear":"2018"
#       },
#       "customer":{
#          "givenName":"Jones",
#          "surname":"Jane",
#          "merchantCustomerId":"jjones",
#          "sex":"F",
#          "email":"jane@jones.com"
#       },
#       "customParameters":{
#          "SHOPPER_promoCode":"AT052"
#       },
#       "risk":{
#          "score":"0"
#       },
#       "buildNumber":"ec3c704170e54f6d7cf86c6f1969b20f6d855ce5@2015-12-01 12:20:39 +0000",
#       "timestamp":"2015-12-07 16:46:07+0000",
#       "ndc":"8a8294174b7ecb28014b9699220015ca_66b12f658442479c8ca66166c4999e78"
#    }
# }
