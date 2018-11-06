defmodule ParkappWeb.ApiIntegration.GenServers.ReservationStateCacheTest do
  use ParkappWeb.ConnCase

  alias ParkappWeb.ApiIntegration.GenServers.{
    ReservationStateCache,
    ReservationState
  }

  describe "ReservationStateCache Test" do
    @pid :"1"

    def assert_init() do
      if !ReservationStateCache.exists?() do
        assert ReservationStateCache.init() |> is_atom()
      end

      assert ReservationStateCache.exists?() == true
    end

    def assert_terminate() do
      if ReservationStateCache.exists?() do
        assert ReservationStateCache.terminate()
      end

      assert ReservationStateCache.exists?() == false
    end

    def assert_stash_state(state \\ %ReservationState{}) do
      assert_init()
      assert ReservationStateCache.stash_state(@pid, state)
      assert ReservationStateCache.get_stash(@pid) == state
    end

    def assert_raise_argument_error(function) do
      assert_raise(ArgumentError, function)
    end

    test "init/0 should create the table" do
      assert_init()
    end

    test "everything should raise ArgumentError if table does not exist" do
      assert_terminate()
      assert ReservationStateCache.exists?() == false

      assert_raise_argument_error(fn ->
        ReservationStateCache.stash_state(@pid, %ReservationState{})
      end)

      assert_raise_argument_error(fn ->
        ReservationStateCache.get_stash(@pid)
      end)

      assert_raise_argument_error(fn ->
        assert ReservationStateCache.clean_stash(@pid)
      end)

      assert_raise_argument_error(fn ->
        ReservationStateCache.terminate()
      end)
    end

    test "exists?/0 should return true if table exists" do
      assert_init()
      assert ReservationStateCache.exists?() == true
    end

    test "exists?/0 should return false if table does not exist" do
      assert_terminate()
      assert ReservationStateCache.exists?() == false
    end

    test "stash_state/2 should insert into the table" do
      assert_stash_state()
    end

    test "stash_state/2 should update the state for an existing pid" do
      assert_stash_state()
      new_state = %ReservationState{reservation_id: 10}
      assert ReservationStateCache.stash_state(@pid, new_state)
      assert ReservationStateCache.get_stash(@pid) == new_state
    end

    test "get_stash/1 should return the default state if key does not exist" do
      assert_init()
      assert ReservationStateCache.get_stash(:invalid_pid) == %ReservationState{}
    end

    test "clean_stash/1 should delete pid from table" do
      state = %ReservationState{reservation_id: 10}
      assert_stash_state(state)
      assert ReservationStateCache.clean_stash(@pid)
      assert ReservationStateCache.get_stash(@pid) == %ReservationState{}
    end

    test "clean_stash/1 should do nothing if pid does not exist" do
      assert_init()
      assert ReservationStateCache.clean_stash(@pid)
    end

    test "terminate/0 should delete the table" do
      assert_stash_state()
      assert ReservationStateCache.terminate()
      assert ReservationStateCache.exists?() == false
    end
  end
end
