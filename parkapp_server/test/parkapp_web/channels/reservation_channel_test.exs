defmodule ParkappWeb.ReservationChannelTest do
  use ParkappWeb.ChannelCase

  alias ParkappWeb.ReservationChannel
  alias ParkappWeb.ApiIntegration.GenServers.Reservation
  alias Parkapp.DataCase
  alias Parkapp.ReservationsContext
  alias Parkapp.Reservations.ReservationStatus.Enum
  alias ParkappWeb.ConnCase
  alias ParkappWeb.Utils

  setup do
    {token, device_id} = ConnCase.get_jwt_token()
    reservation = DataCase.reservation_fixture(device_id)

    {:ok, %{message: "joined"}, socket} =
      socket("socket_id", %{})
      |> subscribe_and_join(ReservationChannel, "reservation:*", %{"token" => token})

    {:ok, socket: socket, token: token, reservation: reservation}
  end

  def assert_start(socket, token, reservation_id) do
    ref = push(socket, "START", %{"token" => token})
    assert_reply(ref, :ok, %{message: "success"})
    assert true == Reservation.exists?(Reservation.get_pid(reservation_id))
  end

  def assert_set_state_event() do
    assert_push(
      "set_state",
      %{
        reservation: reservation
      },
      5000
    )

    reservation
  end

  def refute_set_state_event() do
    refute_push(
      "set_state",
      %{},
      2000
    )
  end

  test "START replies with status ok", %{socket: socket, token: token} do
    ref = push(socket, "START", %{"token" => token})
    assert_reply(ref, :ok, %{message: "success"})
    leave(socket)
  end

  test "START inits the verify_state that updates the reservation from open to in park", %{
    socket: socket,
    token: token,
    reservation: reservation
  } do
    assert reservation.reservation_status_id == Enum.open()
    assert_start(socket, token, reservation.id)

    %{status: status} = assert_set_state_event()

    assert status == Enum.in_park()
    leave(socket)
  end

  # For this test to work the mock needs to return presence of 1

  # test "START inits the verify_state that updates the reservation from open to closed if the user takes too long", %{
  #   socket: socket,
  #   token: token,
  #   reservation: reservation
  # } do
  #   assert reservation.reservation_status_id == Enum.open()
  #   assert_start(socket, token, reservation.id)
  #
  #   %{status: status} = assert_set_state_event()
  #
  #   assert status == Enum.closed()
  #   leave(socket)
  # end

  test "START inits the verify_state that updates the reservation from payment2 to in park", %{
    socket: socket,
    token: token,
    reservation: reservation
  } do
    {:ok, reservation} =
      ReservationsContext.move_reservation_from_to(reservation, Enum.open(), Enum.payment2())

    assert reservation.reservation_status_id == Enum.payment2()
    assert_start(socket, token, reservation.id)

    %{status: status} = assert_set_state_event()

    assert status == Enum.in_park()
    leave(socket)
  end

  test "START inits the verify_state that keeps the reservation in external_payment", %{
    socket: socket,
    token: token,
    reservation: reservation
  } do
    {:ok, reservation} =
      ReservationsContext.move_reservation_from_to(
        reservation,
        Enum.open(),
        Enum.external_payment()
      )

    assert reservation.reservation_status_id == Enum.external_payment()
    assert_start(socket, token, reservation.id)

    refute_set_state_event()

    assert ReservationsContext.get_reservation!(reservation.id).reservation_status_id ==
             Enum.external_payment()

    leave(socket)
  end

  test "START updates the websocket if called twice", %{
    socket: socket,
    token: token,
    reservation: reservation
  } do
    assert reservation.reservation_status_id == Enum.open()
    assert_start(socket, token, reservation.id)

    %{status: status} = assert_set_state_event()

    assert status == Enum.in_park()

    {:ok, %{message: "joined"}, new_socket} =
      socket("new_socket_id", %{})
      |> subscribe_and_join(ReservationChannel, "reservation:*", %{"token" => token})

    assert_start(new_socket, token, reservation.id)

    assert {:ok, reservation} =
             ReservationsContext.get_reservation!(reservation.id)
             |> ReservationsContext.move_reservation_from_to(
               Enum.in_park(),
               Enum.payment2()
             )

    %{status: status} = assert_set_state_event()
    assert status == Enum.in_park()
    leave(socket)
    leave(new_socket)
  end

  test "START pushes a reservation not found if the reservations is closed", %{
    socket: socket,
    token: token,
    reservation: reservation
  } do
    {:ok, reservation} = ReservationsContext.close_reservation(reservation)

    assert reservation.reservation_status_id == Enum.closed()
    ref = push(socket, "START", %{"token" => token})
    assert_reply(ref, :ok, %{message: "success"})

    assert false == Reservation.exists?(Reservation.get_pid(reservation.id))
    %{status: status} = assert_set_state_event()

    assert status == 0
    leave(socket)
  end

  test "START replies with status error if token is invalid", %{socket: socket} do
    ref = push(socket, "START", %{"token" => ""})
    assert_reply(ref, :error, %{error: "unauthorized"})
    leave(socket)
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push("broadcast", %{"some" => "data"})
    leave(socket)
  end

  describe "Reservation GenServer" do
    test "update_socket/1 should update the socket", %{
      socket: socket,
      token: token,
      reservation: reservation
    } do
      assert reservation.reservation_status_id == Enum.open()
      assert_start(socket, token, reservation.id)

      {:ok, %{message: "joined"}, new_socket} =
        socket("new_socket_id", %{})
        |> subscribe_and_join(ReservationChannel, "reservation:*", %{"token" => token})

      assert state =
               Reservation.get_pid(reservation.id)
               |> Reservation.update_websocket(new_socket)

      assert state.websocket != socket
      assert state.websocket == new_socket
      leave(socket)
      leave(new_socket)
    end

    test "stop/1 should stop the gen server", %{
      socket: socket,
      token: token,
      reservation: reservation
    } do
      assert_start(socket, token, reservation.id)
      gen_server_id = Reservation.get_pid(reservation.id)

      Reservation.stop(gen_server_id)

      assert_push("terminating", %{reservation_id: reservation_id})
      assert reservation_id == reservation.id

      leave(socket)
    end

    # this test needs to be ran alone for it to work, plus remove the if in the Gen Server that checks the Mix.env. the handle_info must always shut down if the conditions are met

    # test "should stop if reservation id does not exist", %{
    #   socket: socket
    # } do
    #   pid = Reservation.get_pid(0)
    #
    #   start_supervised!(%{
    #     id: pid,
    #     start: {Reservation, :start_link, [name: pid]}
    #   })
    #
    #   Reservation.init(pid, socket, 0)
    #   Reservation.start_checking(pid)
    #   assert_push("terminating", %{reservation_id: reservation_id}, 5000)
    #   assert reservation_id == 0
    #
    #   leave(socket)
    # end

    test "Utils.push_reservation_to_client/1 should push the given reservation to the websocket",
         %{
           socket: socket,
           token: token,
           reservation: reservation
         } do
      assert_start(socket, token, reservation.id)

      assert {:ok, reservation} = ReservationsContext.close_reservation(reservation)
      # because the reservation is closed, the scheduler stops
      assert_set_state_event()
      # make sure it stopped
      refute_set_state_event()
      # now we can correctly test the Utils function
      assert(:ok == Utils.push_reservation_to_client(reservation))

      rendered_reservation = assert_set_state_event()

      assert rendered_reservation ==
               ParkappWeb.ReservationView.render("reservation.json", %{reservation: reservation}).reservation

      leave(socket)
    end
  end
end
