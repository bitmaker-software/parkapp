defmodule Parkapp.LoggingTest do
  use Parkapp.DataCase

  alias Parkapp.Logging

  describe "external_payment_logs" do
    alias Parkapp.Logging.ExternalPaymentLog

    @valid_attrs %{body: "some params", result_code: "some code", received_at: "2010-04-17 14:00:00.000000Z"}
    @update_attrs %{body: "some updated params", result_code: "some updated code", received_at: "2011-05-18 15:01:01.000000Z"}
    @invalid_attrs %{body: nil, result_code: nil, received_at: nil}

    def local_external_payment_log_fkey_fix() do
      reservation_fixture().id
    end

    def local_external_payment_log_fixture(attrs \\ %{}) do
      reservation_id = local_external_payment_log_fkey_fix()

      {:ok, external_payment_log} =
        attrs
        |> Map.put(:reservation_id, reservation_id)
        |> Enum.into(@valid_attrs)
        |> Logging.create_external_payment_log()

      external_payment_log
    end

    test "list_external_payment_logs/0 returns all external_payment_logs" do
      external_payment_log = local_external_payment_log_fixture()
      assert Logging.list_external_payment_logs() == [external_payment_log]
    end

    test "list_external_payment_logs/1 returns all external_payment_logs for the given reservation_id" do
      external_payment_log = local_external_payment_log_fixture()
      assert Logging.list_external_payment_logs(external_payment_log.reservation_id) == [external_payment_log]
    end

    test "get_external_payment_log!/1 returns the external_payment_log with given id" do
      external_payment_log = local_external_payment_log_fixture()
      assert Logging.get_external_payment_log!(external_payment_log.id) == external_payment_log
    end

    test "create_external_payment_log/1 with valid data creates a external_payment_log" do
      reservation_id = local_external_payment_log_fkey_fix()

      assert {:ok, %ExternalPaymentLog{} = external_payment_log} =
               Map.put(@valid_attrs, :reservation_id, reservation_id)
               |> Logging.create_external_payment_log()

      assert external_payment_log.body == "some params"
      assert external_payment_log.result_code == "some code"

      assert external_payment_log.received_at ==
               DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
    end

    test "create_external_payment_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_external_payment_log(@invalid_attrs)
    end

    test "update_external_payment_log/2 with valid data updates the external_payment_log" do
      external_payment_log = local_external_payment_log_fixture()

      assert {:ok, external_payment_log} =
               Logging.update_external_payment_log(external_payment_log, @update_attrs)

      assert %ExternalPaymentLog{} = external_payment_log
      assert external_payment_log.body == "some updated params"
      assert external_payment_log.result_code == "some updated code"

      assert external_payment_log.received_at ==
               DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_external_payment_log/2 with invalid data returns error changeset" do
      external_payment_log = local_external_payment_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Logging.update_external_payment_log(external_payment_log, @invalid_attrs)

      assert external_payment_log == Logging.get_external_payment_log!(external_payment_log.id)
    end

    test "delete_external_payment_log/1 deletes the external_payment_log" do
      external_payment_log = local_external_payment_log_fixture()

      assert {:ok, %ExternalPaymentLog{}} =
               Logging.delete_external_payment_log(external_payment_log)

      assert_raise Ecto.NoResultsError, fn ->
        Logging.get_external_payment_log!(external_payment_log.id)
      end
    end

    test "change_external_payment_log/1 returns a external_payment_log changeset" do
      external_payment_log = local_external_payment_log_fixture()
      assert %Ecto.Changeset{} = Logging.change_external_payment_log(external_payment_log)
    end
  end
end
