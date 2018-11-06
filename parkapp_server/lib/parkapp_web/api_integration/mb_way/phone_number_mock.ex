defmodule ParkappWeb.ApiIntegration.MBWay.PhoneNumberMock do
  @moduledoc """
    Mock implementation of the MBWay API. Replaces the given phone number with a mock one.
  """

  @behaviour ParkappWeb.ApiIntegration.MBWay.Behaviour

  alias ParkappWeb.ApiIntegration.MBWay.API

  def request_payment(user_token, _phone_number, amount) do
    API.request_payment(user_token, "351#911222111", amount)
  end
end
