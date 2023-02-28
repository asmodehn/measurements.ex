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

  describe "convert 2 returns a function to convert a value from one unit to the other" do
    test "" do
      with {:ok, converter} = Unit.convert(:second, :millisecond) do
        assert converter.(42) == 42_000
      end
    end
  end
end
