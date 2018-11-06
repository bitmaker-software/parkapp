defmodule ParkappWeb.ApiIntegration.Embers.Behaviour do
  @moduledoc """
    Defines the interface for every implementation of Embers API
  """

  @callback get_route(String, String, String) :: {:ok, Map} | {:error, Map} | nil
  @callback get_reservation(String) :: {:ok, Map} | {:error, Map} | nil
  @callback make_reservation(String) :: {:ok, Map} | {:error, Map} | nil
  @callback cancel_reservation(String) :: {:ok, Map} | {:error, Map} | nil
  @callback delete_reservation(String) :: {:ok, nil} | {:error, Map} | nil
  @callback payment1(String) :: {:ok, Map} | {:error, Map} | nil
  @callback payment2(String) :: {:ok, Map} | {:error, Map} | nil
end
