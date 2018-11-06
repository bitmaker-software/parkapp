defmodule ParkappWeb.Router do
  use ParkappWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :unauthorized do
    plug(:fetch_session)
  end

  pipeline :authorized do
    plug(ParkappWeb.Auth.GuardianPipeline)
  end

  pipeline :mock_authorized do
    plug(ParkappWeb.Auth.MockGuardianPipeline)
  end

  scope "/", ParkappWeb.HTML do
    pipe_through([:browser, :unauthorized])
    get("/", HomeController, :current_version)
    get("/login", AuthenticationController, :login)
    post("/login", AuthenticationController, :process_login)

    scope "/mock_reservation" do
      pipe_through([:mock_authorized])
      get("/", MockReservationController, :index)
      get("/new", MockReservationController, :new)
      post("/create", MockReservationController, :create)
      delete("/clear", MockReservationController, :clear_all_reservations)
      get("/:id", MockReservationController, :show)
      put("/:id/open", MockReservationController, :move_to_open)
      put("/:id/inpark", MockReservationController, :move_to_inpark)
      put("/:id/external_payment", MockReservationController, :move_to_external_payment)
      put("/:id/payment2", MockReservationController, :move_to_payment2)
      put("/:id/closed", MockReservationController, :move_to_closed)
      get("/:id/edit", MockReservationController, :edit)
      put("/:id/update", MockReservationController, :update)
      get("/:id/edit_amount", MockReservationController, :edit_amount)
      get("/:id/edit_cancel", MockReservationController, :edit_cancel)
      put("/:id/set_amount", MockReservationController, :set_amount)
    end

    scope "/device" do
      pipe_through([:mock_authorized])
      get("/", DeviceController, :index)
      get("/new", DeviceController, :new)
      post("/generate_new", DeviceController, :generate_new)
      post("/create", DeviceController, :create)
      get("/:id", DeviceController, :show)
      get("/:id/edit", DeviceController, :edit)
      put("/:id/update", DeviceController, :update)
    end
  end

  # New scope we will be using
  scope "/api/v1", ParkappWeb do
    pipe_through(:api)

    scope "/account" do
      scope "/" do
        pipe_through(:unauthorized)
        post("/register", AuthenticationController, :register)
        post("/authenticate_phase1", AuthenticationController, :authenticate_phase1)
        post("/authenticate_phase2", AuthenticationController, :authenticate_phase2)
      end

      scope "/" do
        pipe_through(:authorized)
        post("/logout", AuthenticationController, :logout)
        get("/verify_token", AuthenticationController, :verify_token)
      end
    end

    scope "/routing" do
      pipe_through(:authorized)

      get("/route", RoutingController, :route)
    end

    scope "/reservation" do
      pipe_through(:authorized)

      get("/current", ReservationController, :get_current_reservation_payment)
      post("/reserve", ReservationController, :reserve)
      post("/book", ReservationController, :book)
      put("/in_park", ReservationController, :in_park)#might be useless
      put("/cancel", ReservationController, :cancel_reservation)
      put("/payment1", ReservationController, :payment1)
      put("/pay", ReservationController, :pay)
      put("/close", ReservationController, :close)#might be useless
    end

    scope "/webhooks" do
      pipe_through(:unauthorized)

      post("/mbway", ReservationController, :complete_payment)
    end
  end
end
