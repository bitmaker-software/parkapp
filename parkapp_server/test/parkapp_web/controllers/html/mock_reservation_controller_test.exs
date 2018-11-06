defmodule ParkappWeb.HTML.MockReservationControllerTest do
  use ParkappWeb.ConnCase

  alias Parkapp.DataCase
  alias Parkapp.Reservations.ReservationType
  alias Parkapp.Reservations.ReservationStatus
  alias Parkapp.ReservationsContext

  @create_attrs %{
    reservation_type_id: ReservationType.Enum.single_use(),
    barcode: "some barcode",
    locator: "some locator",
    reservation_start_time: DateTime.utc_now()
  }
  @invalid_attrs %{barcode: ""}
  @updated_barcode "new barcode"
  @update_attrs %{barcode: @updated_barcode}
  @updated_amount "50"
  @update_amount_attrs %{amount: @updated_amount}

  describe "index" do
    @tag :with_auth
    test "lists all devices", %{conn: conn} do
      conn = get(conn, mock_reservation_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Reservations"
    end
  end

  describe "new reservation" do
    @tag :with_auth
    test "renders form", %{conn: conn} do
      conn = get(conn, mock_reservation_path(conn, :new))
      assert html_response(conn, 200) =~ "New Reservation"
    end
  end

  describe "create reservation" do
    @tag :with_auth
    test "redirects to show when data is valid", %{conn: auth_conn} do
      device = DataCase.device_fixture()
      attrs = Map.put(@create_attrs, :device_id, device.device_id)
      conn = post(auth_conn, mock_reservation_path(auth_conn, :create), reservation: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == mock_reservation_path(conn, :show, id)

      conn = get(auth_conn, mock_reservation_path(auth_conn, :show, id))
      assert html_response(conn, 200) =~ "Show Reservation"
    end

    @tag :with_auth
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, mock_reservation_path(conn, :create), reservation: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Reservation"
    end
  end

  describe "clear all reservations" do
    setup [:create_reservation]

    @tag :with_auth
    test "deletes all reservations and redirects to mock_reservation index", %{
      conn: conn,
      reservation: _reservation
    } do
      conn = delete(conn, mock_reservation_path(conn, :clear_all_reservations))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)
    end
  end

  describe "edit reservation" do
    setup [:create_reservation]

    @tag :with_auth
    test "renders form for editing chosen reservation", %{conn: conn, reservation: reservation} do
      conn = get(conn, mock_reservation_path(conn, :edit, reservation))
      assert html_response(conn, 200) =~ "Edit Reservation"
    end
  end

  describe "edit amount reservation" do
    setup [:create_reservation]

    @tag :with_auth
    test "renders form for editing chosen reservation's amount", %{
      conn: conn,
      reservation: reservation
    } do
      conn = get(conn, mock_reservation_path(conn, :edit_amount, reservation))
      assert html_response(conn, 200) =~ "Set Amount"
    end
  end

  describe "edit cancel reservation" do
    setup [:create_reservation]

    @tag :with_auth
    test "renders form for editing chosen reservation's cancelled_at", %{
      conn: conn,
      reservation: reservation
    } do
      conn = get(conn, mock_reservation_path(conn, :edit_cancel, reservation))
      assert html_response(conn, 200) =~ "Set Cancel Time"
    end
  end

  describe "update reservation" do
    setup [:create_reservation]

    @tag :with_auth
    test "redirects when data is valid", %{conn: auth_conn, reservation: reservation} do
      conn =
        put(auth_conn, mock_reservation_path(auth_conn, :update, reservation),
          reservation: @update_attrs
        )

      assert redirected_to(conn) == mock_reservation_path(conn, :show, reservation)

      conn = get(auth_conn, mock_reservation_path(auth_conn, :show, reservation))
      assert html_response(conn, 200) =~ @updated_barcode
    end

    @tag :with_auth
    test "renders errors when data is invalid", %{conn: conn, reservation: reservation} do
      conn =
        put(conn, mock_reservation_path(conn, :update, reservation), reservation: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Reservation"
    end
  end

  describe "set_amount reservation" do
    setup [:create_reservation]

    @tag :with_auth
    test "redirects when data is valid", %{conn: auth_conn, reservation: reservation} do
      conn =
        put(auth_conn, mock_reservation_path(auth_conn, :set_amount, reservation),
          reservation: @update_amount_attrs
        )

      assert redirected_to(conn) == mock_reservation_path(conn, :show, reservation)

      conn = get(auth_conn, mock_reservation_path(auth_conn, :show, reservation))
      assert html_response(conn, 200) =~ @updated_amount
    end

    @tag :with_auth
    test "renders errors when data is invalid", %{conn: conn, reservation: reservation} do
      conn =
        put(conn, mock_reservation_path(conn, :set_amount, reservation), reservation: @invalid_attrs)

      assert html_response(conn, 200) =~ "Set Amount"
    end
  end

  describe "reservation move to open" do
    setup [:create_reservation]

    @tag :with_auth
    test "flash error if is in open state", %{conn: conn, reservation: reservation} do
      conn = put(conn, mock_reservation_path(conn, :move_to_open, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"error" => "Failed to moved to open"}
    end

    @tag :with_auth
    test "flash info if is not in open state", %{conn: conn, reservation: reservation} do
      {:ok, reservation} = ReservationsContext.close_reservation(reservation)

      conn = put(conn, mock_reservation_path(conn, :move_to_open, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"info" => "Moved to open"}
    end
  end

  describe "reservation move to inpark" do
    setup [:create_reservation]

    @tag :with_auth
    test "flash info if is not in inpark state", %{conn: conn, reservation: reservation} do
      conn = put(conn, mock_reservation_path(conn, :move_to_inpark, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"info" => "Moved to inpark"}
    end

    @tag :with_auth
    test "flash error if is in inpark state", %{conn: conn, reservation: reservation} do
      {:ok, reservation} =
        ReservationsContext.move_reservation_from_to(
          reservation,
          reservation.reservation_status_id,
          ReservationStatus.Enum.in_park()
        )

      conn = put(conn, mock_reservation_path(conn, :move_to_inpark, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"error" => "Failed to moved to inpark"}
    end
  end

  describe "reservation move to external_payment" do
    setup [:create_reservation]

    @tag :with_auth
    test "flash info if is not in external_payment state", %{conn: conn, reservation: reservation} do
      conn = put(conn, mock_reservation_path(conn, :move_to_external_payment, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"info" => "Moved to external payment"}
    end

    @tag :with_auth
    test "flash error if is in external_payment state", %{conn: conn, reservation: reservation} do
      {:ok, reservation} =
        ReservationsContext.move_reservation_from_to(
          reservation,
          reservation.reservation_status_id,
          ReservationStatus.Enum.external_payment()
        )

      conn = put(conn, mock_reservation_path(conn, :move_to_external_payment, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"error" => "Failed to moved to external payment"}
    end
  end

  describe "reservation move to payment2" do
    setup [:create_reservation]

    @tag :with_auth
    test "flash info if is not in payment2 state", %{conn: conn, reservation: reservation} do
      conn = put(conn, mock_reservation_path(conn, :move_to_payment2, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"info" => "Moved to payment2"}
    end

    @tag :with_auth
    test "flash error if is in payment2 state", %{conn: conn, reservation: reservation} do
      {:ok, reservation} =
        ReservationsContext.move_reservation_from_to(
          reservation,
          reservation.reservation_status_id,
          ReservationStatus.Enum.payment2()
        )

      conn = put(conn, mock_reservation_path(conn, :move_to_payment2, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"error" => "Failed to moved to payment2"}
    end
  end

  describe "reservation move to closed" do
    setup [:create_reservation]

    @tag :with_auth
    test "flash info if is not in closed state", %{conn: conn, reservation: reservation} do
      conn = put(conn, mock_reservation_path(conn, :move_to_closed, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"info" => "Moved to closed"}
    end

    @tag :with_auth
    test "flash error if is in closed state", %{conn: conn, reservation: reservation} do
      {:ok, reservation} = ReservationsContext.close_reservation(reservation)

      conn = put(conn, mock_reservation_path(conn, :move_to_closed, reservation))

      assert redirected_to(conn) == mock_reservation_path(conn, :index)

      assert get_flash(conn) == %{"error" => "Failed to moved to closed"}
    end
  end

  describe "unauthorize" do
    setup [:create_reservation]

    test "all mock_reservation routes", %{conn: conn, reservation: reservation} do
      Enum.each(
        [
          get(conn, mock_reservation_path(conn, :index)),
          get(conn, mock_reservation_path(conn, :new)),
          post(conn, mock_reservation_path(conn, :create), reservation: @create_attrs),
          delete(conn, mock_reservation_path(conn, :clear_all_reservations)),
          get(conn, mock_reservation_path(conn, :show, reservation)),
          put(conn, mock_reservation_path(conn, :move_to_open, reservation)),
          put(conn, mock_reservation_path(conn, :move_to_inpark, reservation)),
          put(conn, mock_reservation_path(conn, :move_to_external_payment, reservation)),
          put(conn, mock_reservation_path(conn, :move_to_payment2, reservation)),
          put(conn, mock_reservation_path(conn, :move_to_closed, reservation)),
          get(conn, mock_reservation_path(conn, :edit, reservation)),
          put(conn, mock_reservation_path(conn, :update, reservation), reservation: @update_attrs),
          get(conn, mock_reservation_path(conn, :edit_amount, reservation)),
          get(conn, mock_reservation_path(conn, :edit_cancel, reservation)),
          put(conn, mock_reservation_path(conn, :set_amount, reservation),
            reservation: @update_amount_attrs
          )
        ],
        fn conn ->
          assert redirected_to(conn) == authentication_path(conn, :login)
        end
      )
    end
  end

  defp create_reservation(_) do
    reservation = DataCase.reservation_fixture()
    {:ok, reservation: reservation}
  end
end
