defmodule ParkappWeb.ReservationView do
  use ParkappWeb, :view

  def render("reservation.json", %{reservation: reservation}) do
    %{
      reservation: %{
        barcode: reservation.barcode,
        status: reservation.reservation_status_id,
        type: reservation.reservation_type_id,
        amount: format_amount(reservation.amount),
        reservation_start_time: reservation.reservation_start_time,
        parking_start_time: reservation.parking_start_time,
        cancelled: reservation.cancelled
      }
    }
  end

  def render("reservation_payment.json", %{reservation: reservation, amount: amount}) do
    %{
      reservation: %{
        barcode: reservation.barcode,
        status: reservation.reservation_status_id,
        type: reservation.reservation_type_id,
        amount: format_amount(amount),
        reservation_start_time: reservation.reservation_start_time,
        parking_start_time: reservation.parking_start_time,
        cancelled: reservation.cancelled
      }
    }
  end

  def render("reservation_not_found.json", _params) do
    %{
      reservation: %{
        status: 0,
        type: nil,
        amount: nil,
        reservation_start_time: nil,
        parking_start_time: nil,
        cancelled: false
      }
    }
  end

  @spec format_amount(String) :: String
  defp format_amount(nil), do: "0"
  defp format_amount(amount), do: amount
end
