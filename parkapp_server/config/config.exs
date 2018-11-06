# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :parkapp,
  ecto_repos: [Parkapp.Repo],
  secret_length: 256,
  private_key_path: "/priv/keys/private_test_key.key"

# Configures the endpoint
config :parkapp, ParkappWeb.Endpoint,
  url: [host: "localhost"],
  # You can generate a new secret by running:
  #
  #     mix phx.gen.secret
  secret_key_base: "ZAzEkczJ/F/lS22HH73JyN564jwdMHrb6RhJ7XbnRbG8dd0Jw2POj8YRDUdYixtE",
  render_errors: [view: ParkappWeb.ErrorView, accepts: ~w(json html)],
  pubsub: [name: Parkapp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :parkapp, ParkappWeb.Auth.Guardian,
  issuer: "parkapp",
  # {:system, "GUARDIAN_DEMO_SECRET_KEY"}
  secret_key: "Ao/6VUcwPXNqDgI30/6NlkgCRjTgQh4q3v1wRCmhBR4NA9BTG65rYHZNCujia6Qs",
  ttl: {2, :hour}

config :parkapp, :embers_api,
  routing: %{
    api_key: "bdde8760-90de-48a9-8d9d-bc61b25ffb56",
    max_walk_distance: "500"
  },
  trindade_park: %{
    api_key: "dacc46d9-3cb8-4a09-997b-ed2daa822c95",
    # in minutes
    park_time_available: 30
  },
  module: ParkappWeb.ApiIntegration.Embers.ProductionMock,
  domain: "https://api.embers.city",
  public_transportation_agencies_time_zone: "Europe/Berlin"

config :parkapp, :mb_way_api,
  module: ParkappWeb.ApiIntegration.MBWay.PhoneNumberMock,
  domain: "https://test.onlinepayments.pt/v1",
  user_id: "8a8294185b674555015b7c1928e81736",
  entity_id: "8a8294185bd901c5015be855fd5f1578",
  password: "Rr47eQesdW",
  payment_brand: "MBWAY",
  currency: "EUR",
  payment_type: "DB",
  decrypt_secret: "33B62F65204D2F60A363C372DF19960828DFA4733016D3EBA4BBF38CBE3C29D5"

# 78495527-0b07-4b93-b0ce-e0ef8fc04957
# "timestamp": "2018-09-19T11:03:36.568316Z",
#     "occupied_spots": 51,
#     "free_spots": 449,

# "timestamp": "2018-09-24T07:08:23.703824Z",
#       "occupied_spots": 54,
#       "free_spots": 446,
# "timestamp": "2018-09-26T12:08:22.505572Z",
#       "occupied_spots": 90,
#       "free_spots": 410,
# curl -X GET "https://api.embers.city/offstreet-parking/occupancy-reports/?ordering=timestamp&parking_area=85&timestamp__gte=2018-09-19T11%3A03%3A36.568316Z" -H "accept: application/json" -H "X-Gravitee-Api-Key: 78495527-0b07-4b93-b0ce-e0ef8fc04957"

config :parkapp, :reservations_gen_server,
  # in miliseconds
  schedule_interval: 1000,
  # in seconds, should be related to park_time_available
  time_to_enter_park: 600,
  # in seconds
  time_to_enter_park_after_book: 1800,
  # in seconds
  time_to_pay: 300,
  # 30 days in seconds
  cancel_reservation_ban_time: 30 * 24 * 60 * 60,
  # possible mocks:
  # ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSyncMock
  # ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSyncOpenBookedTimeoutMock
  sync_state_module: ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSync

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
