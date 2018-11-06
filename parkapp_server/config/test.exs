use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :parkapp, ParkappWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :parkapp, Parkapp.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "parkapp_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :parkapp, :embers_api, module: ParkappWeb.ApiIntegration.Embers.Mock

config :parkapp, :mb_way_api,
  module: ParkappWeb.ApiIntegration.MBWay.Mock,
  decrypt_secret: "33B62F65204D2F60A363C372DF19960828DFA4733016D3EBA4BBF38CBE3C29D5"

config :parkapp, :reservations_gen_server,
  # in miliseconds
  schedule_interval: 100,
  # in seconds
  time_to_enter_park: 1,
  # in seconds
  cancel_reservation_ban_time: 600,
  sync_state_module: ParkappWeb.ApiIntegration.GenServers.StateSync.ReservationStateSync
