defmodule ParkappWeb.Auth.GuardianPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :parkapp,
    module: ParkappWeb.Auth.Guardian,
    error_handler: ParkappWeb.Auth.Guardian.ErrorHandler

  # If there is a session token, validate it
  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  # If there is an authorization header, validate it
  plug(Guardian.Plug.VerifyHeader, realm: "Bearer", claims: %{"typ" => "access"})
  plug(Guardian.Plug.EnsureAuthenticated)
  # Load the device if either of the verifications worked
  plug(Guardian.Plug.LoadResource)
end

defmodule ParkappWeb.Auth.MockGuardianPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :parkapp,
    module: ParkappWeb.Auth.Guardian,
    error_handler: ParkappWeb.Auth.Guardian.BrowserErrorHandler

  # If there is a session token, validate it
  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  # If there is an authorization header, validate it
  plug(Guardian.Plug.VerifyHeader, realm: "Bearer", claims: %{"typ" => "access"})
  plug(Guardian.Plug.EnsureAuthenticated)
end
