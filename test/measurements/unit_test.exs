defmodule Measurements.UnitTest do
  use ExUnit.Case
  doctest Measurements.Unit

  alias Measurements.Unit

  describe "time/1 normalizes a unit if it represents time" do
    test "second, millisecond, microsecond, nanosecond" do
      assert Unit.time(:second) == {:ok, :second}
      assert Unit.time(:millisecond) == {:ok, :millisecond}
      assert Unit.time(:microsecond) == {:ok, :microsecond}
      assert Unit.time(:nanosecond) == {:ok, :nanosecond}
    end
  end

  describe "convert/2" do
    test " returns a function to convert a value from one unit to the other" do
      {:ok, converter} = Unit.convert(:second, :millisecond)
      assert converter.(42) == 42_000
    end
  end

  describe "min/2 " do
    test "returns the unit with smaller scale / more precision" do
      assert Unit.min(:second, :microsecond) == {:ok, :microsecond}
    end
  end

  describe "max/2 " do
    test "returns the unit with bigger scale / less precision" do
      assert Unit.max(:second, :microsecond) == {:ok, :second}
    end
  end
end
