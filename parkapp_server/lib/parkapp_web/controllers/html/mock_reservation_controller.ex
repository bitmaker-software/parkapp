defmodule ParkappWeb.HTML.MockReservationController do
  @moduledoc """
  """
  use ParkappWeb, :controller

  alias Parkapp.ReservationsContext
  alias Parkapp.Reservations.ReservationStatus.Enum, as: ReservationStatusEnum
  alias Parkapp.Reservations.Reservation
  alias ParkappWeb.Utils

  def index(conn, _params) do
    reservations = ReservationsContext.list_reservations_order_by_inserted()

    render(conn, "index.html", reservations: reservations)
  end

  def new(conn, _params) do
    changeset = ReservationsContext.change_reservation(%Reservation{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"reservation" => reservation_params}) do
    reservation_params = convert_map_of_key_strings_to_key_atoms(reservation_params)

    case ReservationsContext.create_reservation_initial_state(reservation_params) do
      {:ok, reservation} ->
        conn
        |> put_flash(:info, "Reservation created successfully.")
        |> redirect(to: mock_reservation_path(conn, :show, reservation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    reservation = ReservationsContext.get_reservation!(id)

    render(conn, "show.html", reservation: reservation)
  end

  def clear_all_reservations(conn, _params) do
    ReservationsContext.delete_all_reservations()

    conn
    |> put_flash(:info, "Reservations deleted successfully.")
    |> redirect(to: mock_reservation_path(conn, :index))
  end

  def move_to_open(conn, %{"id" => id}) do
    handle_move(
      conn,
      id,
      ReservationStatusEnum.open(),
      "Moved to open",
      "Failed to moved to open",
      fn ->
        ReservationsContext.get_reservation!(id)
        |> ReservationsContext.update_reservation(%{
          reservation_start_time: DateTime.utc_now()
        })
      end
    )
  end

  def move_to_inpark(conn, %{"id" => id}) do
    handle_move(
      conn,
      id,
      ReservationStatusEnum.in_park(),
      "Moved to inpark",
      "Failed to moved to inpark",
      fn ->
        ReservationsContext.get_reservation!(id)
        |> ReservationsContext.update_reservation_inpark(%{parking_start_time: DateTime.utc_now()})
      end
    )
  end

  def move_to_external_payment(conn, %{"id" => id}) do
    handle_move(
      conn,
      id,
      ReservationStatusEnum.external_payment(),
      "Moved to external payment",
      "Failed to moved to external payment",
      fn ->
        reservation = ReservationsContext.get_reservation!(id)

        ReservationsContext.update_reservation_after_payment1(reservation, %{
          context_token: "some context_token",
          amount: get_value(reservation, :amount, "5"),
          payment1_time: DateTime.utc_now()
        })
      end
    )
  end

  def move_to_payment2(conn, %{"id" => id}) do
    handle_move(
      conn,
      id,
      ReservationStatusEnum.payment2(),
      "Moved to payment2",
      "Failed to moved to payment2",
      fn ->
        ReservationsContext.get_reservation!(id)
        |> ReservationsContext.update_reservation_after_payment2(%{
          parking_payment_time: DateTime.utc_now()
        })
      end
    )
  end

  def move_to_closed(conn, %{"id" => id}) do
    handle_move(
      conn,
      id,
      ReservationStatusEnum.closed(),
      "Moved to closed",
      "Failed to moved to closed"
    )
  end

  defp handle_move(
         conn,
         id,
         to,
         success,
         fail,
         success_fn \\ fn -> nil end,
         fail_fn \\ fn -> nil end
       ) do
    case move_to(
           id,
           to
         ) do
      {:ok, _reservation} ->
        success_fn.()

        ReservationsContext.get_reservation!(id)
        |> Utils.push_reservation_to_client()

        success(conn, success)

      error ->
        IO.inspect(error, label: "error")
        fail_fn.()
        fail(conn, fail)
    end
  end

  defp move_to(id, to) do
    reservation = ReservationsContext.get_reservation!(id)

    ReservationsContext.move_reservation_from_to(
      reservation,
      reservation.reservation_status_id,
      to
    )
  end

  defp success(conn, message) do
    conn
    |> put_flash(:info, message)
    |> redirect(to: mock_reservation_path(conn, :index))
  end

  defp fail(conn, message) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: mock_reservation_path(conn, :index))
  end

  def edit_amount(conn, %{"id" => id}) do
    reservation = ReservationsContext.get_reservation!(id)
    changeset = ReservationsContext.change_payment_reservation(reservation)
    render(conn, "amount_form.html", reservation: reservation, changeset: changeset)
  end

  def edit_cancel(conn, %{"id" => id}) do
    reservation = ReservationsContext.get_reservation!(id)
    changeset = ReservationsContext.change_reservation(reservation)
    render(conn, "cancel_form.html", reservation: reservation, changeset: changeset)
  end

  def set_amount(conn, %{"id" => id, "reservation" => reservation_params}) do
    reservation = ReservationsContext.get_reservation!(id)

    reservation_params =
      convert_map_of_key_strings_to_key_atoms(reservation_params)
      |> Map.put(:context_token, get_value(reservation, :context_token, "some context token"))
      |> Map.put(:payment1_time, get_value(reservation, :payment1_time, DateTime.utc_now()))

    case ReservationsContext.update_reservation_after_payment1(reservation, reservation_params) do
      {:ok, reservation} ->
        conn
        |> put_flash(:info, "Reservation updated successfully.")
        |> redirect(to: mock_reservation_path(conn, :show, reservation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "amount_form.html", reservation: reservation, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    reservation = ReservationsContext.get_reservation!(id)
    changeset = ReservationsContext.change_reservation(reservation)
    render(conn, "edit.html", reservation: reservation, changeset: changeset)
  end

  def update(conn, %{"id" => id, "reservation" => reservation_params}) do
    reservation = ReservationsContext.get_reservation!(id)

    reservation_params = convert_map_of_key_strings_to_key_atoms(reservation_params)

    case ReservationsContext.update_reservation(reservation, reservation_params) do
      {:ok, reservation} ->
        conn
        |> put_flash(:info, "Reservation updated successfully.")
        |> redirect(to: mock_reservation_path(conn, :show, reservation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", reservation: reservation, changeset: changeset)
    end
  end

  defp get_value(reservation, field, default \\ nil)
  defp get_value(nil, _field, default), do: default

  defp get_value(reservation, field, default) when is_atom(field) do
    with(
      field_value <- Map.get(reservation, field),
      false <- is_nil(field_value)
    ) do
      field_value
    else
      _ ->
        default
    end
  end

  defp convert_map_of_key_strings_to_key_atoms(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      cond do
        is_bitstring(k) ->
          {String.to_atom(k), v}

        true ->
          {k, v}
      end
    end)
  end
end
