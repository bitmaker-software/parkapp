defmodule Parkapp.Repo.Migrations.ExpandMbwayLogsFields do
  use Ecto.Migration

  def up do
    rename(table(:external_payment_logs), :params, to: :body)

    alter(table(:external_payment_logs)) do
      add(:result_code, :string)
      modify(:body, :text)
    end
  end

  def down do
    rename(table(:external_payment_logs), :body, to: :params)

    alter(table(:external_payment_logs)) do
      remove(:result_code)
      modify(:params, :string)
    end
  end
end
