defmodule ParkappWeb.ApiIntegration.MBWay.Behaviour do
  @moduledoc """
    Defines the interface for every implementation of MBWay API
  """

  @callback request_payment(String, String, String) :: :ok | :error
end
