defmodule ParkappWeb.RoutingControllerTest do
  use ParkappWeb.ConnCase

  @moduletag :routing_controller

  describe "RoutingController Happy Path" do
    test "GET /route", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(
          routing_path(conn, :route,
            from: "50.93633658100821,6.976017951965332",
            to: "50.944557395196654,6.938767433166504",
            mode: "CAR"
          )
        )

      assert(conn.status == 200)
      assert(String.contains?(conn.resp_body, "instructions"))
      assert(String.contains?(conn.resp_body, "distance"))
      assert(String.contains?(conn.resp_body, "mode"))
      assert(String.contains?(conn.resp_body, "route"))
      assert(String.contains?(conn.resp_body, "lat"))
      assert(String.contains?(conn.resp_body, "long"))
    end
  end

  describe "RoutingController Fail Path with null input" do
    test "GET /route with a null from", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(
          routing_path(conn, :route,
            from: "null",
            to: "50.944557395196654,6.938767433166504",
            mode: "CAR"
          )
        )

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"From cannot be null\"}")
    end

    test "GET /route with a null to", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(
          routing_path(conn, :route,
            from: "50.93633658100821,6.976017951965332",
            to: "null",
            mode: "CAR"
          )
        )

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"To cannot be null\"}")
    end

    test "GET /route with a null mode", %{conn: conn} do
      {jwt, _} = get_jwt_token(conn)

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(
          routing_path(conn, :route,
            from: "50.93633658100821,6.976017951965332",
            to: "50.944557395196654,6.938767433166504",
            mode: "null"
          )
        )

      assert(conn.status == 400)
      assert(conn.resp_body == "{\"error\":\"Mode cannot be null\"}")
    end
  end

  describe "RoutingController Fail Path" do
    test "GET /route with invalid token", %{conn: conn} do
      jwt = ""

      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(routing_path(conn, :route, from: "41,-8", to: "41,10", mode: "CAR"))

      assert(conn.status == 401)
      assert(conn.resp_body == get_unauthorized_message())
    end
  end
end
