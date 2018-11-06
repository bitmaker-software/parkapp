defmodule ParkappWeb.HTML.MockReservationViewTest do
  use ParkappWeb.ConnCase

  alias ParkappWeb.HTML.MockReservationView
  alias Parkapp.DataCase

  describe "MockReservationView Test" do
    test "get_reservation_type_options/0" do
      assert MockReservationView.get_reservation_type_options() |> length() == 2
    end

    test "get_device_options/0" do
      device = DataCase.device_fixture()
      assert MockReservationView.get_device_options() == [{device.device_id, device.device_id}]
    end
  end
end
