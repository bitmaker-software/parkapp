defmodule ParkappWeb.ApiIntegration.Timeout do
  @moduledoc """
    Handles logic behind the several timeouts
  """

  import ParkappWeb.ApiIntegration.Helpers
  alias Parkapp.Reservations.ReservationStatus.Enum, as: ReservationStatusEnum
  alias Parkapp.ReservationsContext

  @doc """
    Determines if the user has taken too long to enter the park
  """
  @spec check_time_to_enter_park_timeout(Reservation) :: Boolean
  def check_time_to_enter_park_timeout(reservation) do
    with(
      true <- reservation.reservation_status_id == ReservationStatusEnum.open(),
      time_to_enter_park <- get_value_from_config(:time_to_enter_park),
      true <- time_has_passed?(reservation.reservation_start_time, time_to_enter_park)
      # once payment 1 is working, this can be improved
    ) do
      true
    else
      _ ->
        false
    end
  end

  @doc """
    Determines if the user has taken too long to enter the park after a booking
  """
  @spec check_time_to_enter_park_after_booking_timeout(Reservation) :: Boolean
  def check_time_to_enter_park_after_booking_timeout(reservation) do
    with(
      true <- reservation.reservation_status_id == ReservationStatusEnum.open(),
      time_to_enter_park_after_book <- get_value_from_config(:time_to_enter_park_after_book),
      true <- time_has_passed?(reservation.reservation_start_time, time_to_enter_park_after_book)
    ) do
      true
    else
      _ ->
        false
    end
  end

  @doc """
    Determines if the user has taken too long to enter the park
  """
  @spec check_time_to_pay_timeout(Reservation) :: Boolean
  def check_time_to_pay_timeout(reservation) do
    with(
      true <- reservation.reservation_status_id == ReservationStatusEnum.in_park(),
      false <- is_nil(reservation.payment1_time),
      time_to_pay <- get_value_from_config(:time_to_pay),
      true <- time_has_passed?(reservation.payment1_time, time_to_pay)
    ) do
      true
    else
      _ ->
        false
    end
  end

  @spec check_time_since_last_cancelled_reservation(String) :: Boolean
  def check_time_since_last_cancelled_reservation(device_id) do
    with(
      reservation <- ReservationsContext.get_last_cancelled_reservation(device_id),
      false <- is_nil(reservation),
      cancel_reservation_ban_time <- get_value_from_config(:cancel_reservation_ban_time),
      false <- time_has_passed?(reservation.cancelled_at, cancel_reservation_ban_time)
    ) do
      false
    else
      _ ->
        true
    end
  end

  @doc """
    Determines the datetime when the ban to the given device will be lifted.
    nil if he is not banned
  """
  @spec get_unban_datetime(String) :: String | nil
  def get_unban_datetime(device_id) do
    with(
      reservation <- ReservationsContext.get_last_cancelled_reservation(device_id),
      false <- is_nil(reservation),
      cancel_reservation_ban_time <- get_value_from_config(:cancel_reservation_ban_time),
      false <- time_has_passed?(reservation.cancelled_at, cancel_reservation_ban_time),
      {:ok, unban_at} <-
        Timex.add(
          reservation.cancelled_at,
          Timex.Duration.from_seconds(cancel_reservation_ban_time)
        )
        |> Timex.format("%Y-%m-%d %H:%M:%S", :strftime)
    ) do
      unban_at
    else
      _ ->
        nil
    end
  end

  @doc """
  Checks if the given max_time has elapsed sinse the given datetime
  """
  @spec time_has_passed?(DateTime, Integer) :: Boolean
  defp time_has_passed?(datetime, max_time_elapsed) do
    DateTime.diff(DateTime.utc_now(), datetime) >= max_time_elapsed
  end
end
