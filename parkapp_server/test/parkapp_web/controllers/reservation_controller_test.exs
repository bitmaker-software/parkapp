defmodule ParkappWeb.ReservationControllerTest do
  use ParkappWeb.ConnCase

  @moduletag :reservation_controller

  alias Parkapp.DataCase

  describe "ReservationController Happy Path" do
    def assert_reservation(jwt, conn) do
      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> post(reservation_path(conn, :reserve))

      assert(conn.status == 200)
      assert(String.contains?(conn.resp_body, "reservation"))
      assert(String.contains?(conn.resp_body, "type\":1"))
      assert(String.contains?(conn.resp_body, "status\":1"))
      assert(String.contains?(conn.resp_body, "reservation_start_time"))
      assert(String.contains?(conn.resp_body, "parking_start_time\":null"))
      assert(String.contains?(conn.resp_body, "barcode\":\"some barcode"))
      assert(String.contains?(conn.resp_body, "amount\":\"0"))

      jwt
    end

    def assert_book(jwt, conn) do
      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> post(reservation_path(conn, :book))

      assert(conn.status == 200)

      assert(String.contains?(conn.resp_body, "reservation"))
      assert(String.contains?(conn.resp_body, "type\":2"))
      assert(String.contains?(conn.resp_body, "status\":1"))
      assert(String.contains?(conn.resp_body, "reservation_start_time"))
      assert(String.contains?(conn.resp_body, "parking_start_time\":null"))
      assert(String.contains?(conn.resp_body, "barcode\":\"some barcode"))
      assert(String.contains?(conn.resp_body, "amount\":\"0"))

      jwt
    end

    def assert_in_park(jwt, conn) do
      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :in_park))

      assert(conn.status == 200)
      assert(conn.resp_body == "{}")
      jwt
    end

    def assert_payment1(jwt, conn) do
      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :payment1))

      assert(conn.status == 200)
      assert(conn.resp_body == "{\"amount\":\"10.00\"}")
      jwt
    end

    def assert_pay(jwt, conn) do
      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :pay, phone_number: "12934498"))

      assert(conn.status == 200)
      assert(conn.resp_body == "{}")
      jwt
    end

    def assert_complete_payment(jwt, conn, device_id) do
      {body, iv, auth_tag} = default_webhook_mock(device_id)

      conn =
        conn
        |> put_req_header("x-initialization-vector", iv)
        |> put_req_header("x-authentication-tag", auth_tag)
        |> post(reservation_path(conn, :complete_payment, encryptedBody: "#{body}"))

      assert(conn.status == 200)
      assert(conn.resp_body == "")
      jwt
    end

    def default_webhook_mock(device_id) do
      %{
        type: "PAYMENT",
        payload: %{
          id: "8a829449515d198b01517d5601df5584",
          paymentType: "DB",
          paymentBrand: "MBWAY",
          amount: "10.0",
          currency: "EUR",
          presentationAmount: "10.0",
          presentationCurrency: "EUR",
          descriptor: "3017.7139.1650 OPP_Channel ",
          merchantTransactionId: "user token",
          result: %{
            code: "000.100.110",
            description: "Request successfully processed in 'Merchant in Integrator Test Mode'",
            possible: "random field"
          },
          authentication: %{
            entityId: "8a8294185282b95b01528382b4940245"
          },
          customParameters: %{
            device_id: "#{device_id}"
          },
          risk: %{
            score: ""
          },
          resultDetails: %{
            cenas: "coisas"
          },
          timestamp: "2015-12-07 16:46:07+0000",
          ndc: "8a8294174b7ecb28014b9699220015ca_66b12f658442479c8ca66166c4999e78",
          virtualAccount: %{
            accountId: "351#911222111"
          }
        }
      }
      |> Poison.encode!()
      |> get_webhook_mock()
    end

    def assert_close(jwt, conn) do
      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :close))

      assert(conn.status == 200)
      assert(conn.resp_body == "{}")
    end

    test "GET /current", %{conn: conn} do
      jwt =
        get_jwt_token(conn)
        |> elem(0)
        |> assert_reservation(conn)
        |> assert_in_park(conn)
        |> assert_payment1(conn)
        |> assert_pay(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(reservation_path(conn, :get_current_reservation_payment))

      assert(conn.status == 200)
      assert(String.contains?(conn.resp_body, "reservation"))
      assert(String.contains?(conn.resp_body, "barcode"))
      assert(String.contains?(conn.resp_body, "status"))
      assert(String.contains?(conn.resp_body, "type"))
      assert(String.contains?(conn.resp_body, "amount"))
      assert(String.contains?(conn.resp_body, "reservation_start_time"))
      assert(String.contains?(conn.resp_body, "parking_start_time"))
    end

    test "POST /reserve", %{conn: conn} do
      get_jwt_token(conn)
      |> elem(0)
      |> assert_reservation(conn)
    end

    test "POST /book", %{conn: conn} do
      get_jwt_token(conn)
      |> elem(0)
      |> assert_book(conn)
    end

    test "PUT /cancel", %{conn: conn} do
      jwt =
        get_jwt_token(conn)
        |> elem(0)
        |> assert_reservation(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :cancel_reservation))

      assert(conn.status == 200)
      assert(conn.resp_body == "{}")
    end

    test "PUT /in_park", %{conn: conn} do
      get_jwt_token(conn)
      |> elem(0)
      |> assert_reservation(conn)
      |> assert_in_park(conn)
    end

    test "PUT /payment1", %{conn: conn} do
      get_jwt_token(conn)
      |> elem(0)
      |> assert_reservation(conn)
      |> assert_in_park(conn)
      |> assert_payment1(conn)
    end

    test "PUT /pay", %{conn: conn} do
      get_jwt_token(conn)
      |> elem(0)
      |> assert_reservation(conn)
      |> assert_in_park(conn)
      |> assert_payment1(conn)
      |> assert_pay(conn)
    end

    test "POST /mbway", %{conn: conn} do
      {jwt, device_id} = get_jwt_token(conn)

      jwt
      |> assert_reservation(conn)
      |> assert_in_park(conn)
      |> assert_payment1(conn)
      |> assert_pay(conn)
      |> assert_complete_payment(conn, device_id)
    end

    test "PUT /close", %{conn: conn} do
      {jwt, device_id} = get_jwt_token(conn)

      jwt
      |> assert_reservation(conn)
      |> assert_in_park(conn)
      |> assert_payment1(conn)
      |> assert_pay(conn)
      |> assert_complete_payment(conn, device_id)
      |> assert_close(conn)
    end

    test "workflow with book", %{conn: conn} do
      {jwt, device_id} = get_jwt_token(conn)

      jwt
      |> assert_book(conn)
      |> assert_in_park(conn)
      |> assert_payment1(conn)
      |> assert_pay(conn)
      |> assert_complete_payment(conn, device_id)
      |> assert_close(conn)
    end
  end

  describe "ReservationController Fail Path with null input" do
    test "PUT /pay with a null phone number", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :pay, phone_number: "null"))

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Phone number cannot be null\"}")
    end

    test "POST /mbway with a null encryptedBody", %{conn: conn} do
      conn =
        conn
        |> post(reservation_path(conn, :complete_payment, encryptedBody: "null"))

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Params cannot be null\"}")
    end

    test "POST /mbway with missing headers", %{conn: conn} do
      {body, _iv, _auth_tag} = default_webhook_mock(Ecto.UUID.generate())

      conn =
        conn
        |> post(reservation_path(conn, :complete_payment, encryptedBody: "#{body}"))

      assert(conn.status == 200)
      assert(conn.resp_body == "")
      # assert(conn.status == 400)
      # assert(conn.resp_body == "{\"error\":\"Something went wrong\"}")
    end
  end

  describe "ReservationController Fail Path" do
    test "GET /current with invalid token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(reservation_path(conn, :get_current_reservation_payment))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end

    test "POST /reserve with invalid token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> post(reservation_path(conn, :reserve))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end

    test "POST /book with invalid token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> post(reservation_path(conn, :book))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end

    test "PUT /cancel with invalid token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :cancel_reservation))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end

    test "PUT /in_park with invalid token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :in_park))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end

    test "PUT /payment1 with invalid token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :payment1))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end

    test "PUT /pay with invalid token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :pay, phone_number: "123234"))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end

    test "PUT /close with invalid token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :close))
        |> put(reservation_path(conn, :close))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end

    test "PUT /pay with no params", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :pay))

      assert(conn.status == 422)
      assert(conn.resp_body == "{\"error\":\"Invalid parameters\"}")
    end

    test "POST /mbway no params", %{conn: conn} do
      conn =
        conn
        |> post(reservation_path(conn, :complete_payment))

      assert(conn.status == 422)
      assert(conn.resp_body == "{\"error\":\"Invalid parameters\"}")
    end

    test "GET /current with no reservation", %{conn: conn} do
      jwt =
        get_jwt_token(conn)
        |> elem(0)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(reservation_path(conn, :get_current_reservation_payment))

      assert(conn.status == 200)

      assert conn.resp_body ==
               "{\"reservation\":{\"type\":null,\"status\":0,\"reservation_start_time\":null,\"parking_start_time\":null,\"cancelled\":false,\"amount\":null}}"
    end

    test "PUT /cancel with no reservation", %{conn: conn} do
      jwt =
        get_jwt_token(conn)
        |> elem(0)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :cancel_reservation))

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Something went wrong\"}")
    end

    test "PUT /in_park with no reservation", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :in_park))

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Something went wrong\"}")
    end

    test "PUT /payment1 with no reservation", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :payment1))

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Something went wrong\"}")
    end

    test "PUT /pay with no reservation", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :pay, phone_number: "12934498"))

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Something went wrong\"}")
    end

    test "POST /mbway with no reservation", %{conn: conn} do
      {body, iv, auth_tag} = default_webhook_mock(DataCase.get_basic_device_attrs().device_id)

      conn =
        conn
        |> put_req_header("x-initialization-vector", iv)
        |> put_req_header("x-authentication-tag", auth_tag)
        |> post(reservation_path(conn, :complete_payment, encryptedBody: "#{body}"))

      assert(conn.status == 200)
      assert(conn.resp_body == "")
      # assert(conn.status == 400)
      # assert(conn.resp_body == "{\"error\":\"Something went wrong\"}")
    end

    test "PUT /close with no reservation", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> put(reservation_path(conn, :close))

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Something went wrong\"}")
    end
  end

  describe "ReservationController Two Devices" do
    test "Two devices workflow", %{conn: conn} do
      conn_2 = conn

      {jwt, device_id} = get_jwt_token(conn)

      jwt =
        jwt
        |> assert_reservation(conn)
        |> assert_in_park(conn)
        |> assert_payment1(conn)
        |> assert_pay(conn)

      {jwt2, device_id2} = get_jwt_token_2(conn_2)

      jwt2 =
        jwt2
        |> assert_reservation(conn_2)
        |> assert_in_park(conn_2)
        |> assert_payment1(conn)
        |> assert_pay(conn_2)
        |> assert_complete_payment(conn_2, device_id2)

      assert_complete_payment(jwt, conn, device_id)
      |> assert_close(conn)

      assert_close(jwt2, conn_2)
    end
  end
end
