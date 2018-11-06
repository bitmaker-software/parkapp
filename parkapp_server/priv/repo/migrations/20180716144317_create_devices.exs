defmodule Parkapp.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices, primary_key: false) do
      add(:device_id, :uuid, primary_key: true)
      add(:key, :text)
      add(:secret, :text)

      timestamps()
    end
  end
end
