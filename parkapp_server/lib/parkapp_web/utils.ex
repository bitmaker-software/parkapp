defmodule ParkappWeb.Utils do
  @moduledoc """
    The Utils module contains generic methods to be used from the ParkappWeb
  """

  alias ParkappWeb.ApiIntegration.GenServers.Reservation, as: ReservationGenServer

  @doc """
    Generates a random string of the given length
  """
  @spec random_string(Integer) :: String
  def random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  @doc """
  Formats a flot with the given number of decimal places.
  If the value is not a flot, it is returned as a string.
  """
  @spec format_float_decimal_places(Float, Integer) :: String
  def format_float_decimal_places(float, num_decimal_places)
      when is_float(float) and is_integer(num_decimal_places) do
    :erlang.float_to_binary(float, decimals: num_decimal_places)
    |> parse_string_to_float()
  end

  def format_float_decimal_places(value, _num_decimal_places), do: "#{value}"

  @doc """
    Parses the given string to float. It is not a string, nil is returned
  """
  @spec parse_string_to_float(String) :: Float | nil
  def parse_string_to_float(value) when is_bitstring(value) do
    case Float.parse(value) do
      :error ->
        nil

      {float, _rest} ->
        float
    end
  end

  def parse_string_to_float(_value), do: nil

  @doc """
    Forces the genserver to push the given reservation to client
  """
  @spec push_reservation_to_client(Reservation) :: :ok
  def push_reservation_to_client(reservation) do
    with(
      pid <- ReservationGenServer.get_pid(reservation.id),
      true <- ReservationGenServer.exists?(pid)
    ) do
      ReservationGenServer.update_client(pid, reservation)
    end

    :ok
  end
end
