defmodule ParkappWeb.UtilsTest do
  use Parkapp.DataCase

  alias ParkappWeb.Utils

  describe "Utils" do
    @length 512

    test "random_string/1 should generate a string of the given length" do
      assert Utils.random_string(@length) |> String.length() == @length
    end

    test "random_string/1 property testing" do
      length_range = for n <- 1..50, do: n * n

      length_range
      |> Enum.each(fn size ->
        assert Utils.random_string(size) |> String.length() == size
      end)
    end

    test "format_float_decimal_places/2 should return a string with the given decimal places" do
      assert Utils.format_float_decimal_places(12.123, 1) == 12.1
      assert Utils.format_float_decimal_places(12.123, 2) == 12.12
      assert Utils.format_float_decimal_places(12.123, 4) == 12.1230
    end

    test "format_float_decimal_places/2 should return the value as a string if it is not a float" do
      assert Utils.format_float_decimal_places(12, 4) == "12"
      assert Utils.format_float_decimal_places("12", 4) == "12"
      assert Utils.format_float_decimal_places(nil, 4) == ""
    end

    test "parse_string_to_float/1 should return a float based on the given string" do
      assert Utils.parse_string_to_float("12.123") == 12.123
      assert Utils.parse_string_to_float("16.123") == 16.123
      assert Utils.parse_string_to_float("") |> is_nil()
      assert Utils.parse_string_to_float(nil) |> is_nil()
      assert Utils.parse_string_to_float(123) |> is_nil()
    end
  end
end
