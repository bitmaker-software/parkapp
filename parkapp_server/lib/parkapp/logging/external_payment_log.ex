defmodule Parkapp.Logging.ExternalPaymentLog do
  use Ecto.Schema
  import Ecto.Changeset

  alias Parkapp.Reservations.Reservation

  schema "external_payment_logs" do
    field(:body, :string)
    field(:result_code, :string)
    field(:received_at, :utc_datetime)

    belongs_to(:reservation, Reservation)

    timestamps()
  end

  @doc false
  def changeset(external_payment_log, attrs) do
    external_payment_log
    |> cast(attrs, [:received_at, :body, :reservation_id, :result_code])
    |> validate_required([:received_at, :body, :reservation_id, :result_code])
    |> foreign_key_constraint(:reservation_id)
  end
end
