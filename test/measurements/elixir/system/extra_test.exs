defmodule Measurements.System.ExtraTest do
  use ExUnit.Case
  doctest Measurements.System.Extra

  alias Measurements.System

  describe "Timeunit is ordered by precision" do
    test " second < millisecond < microsecond < nanosecond " do
      assert System.Extra.time_unit_inf(:second, :millisecond)
      assert System.Extra.time_unit_inf(:second, :microsecond)
      assert System.Extra.time_unit_inf(:second, :nanosecond)
      assert System.Extra.time_unit_inf(:millisecond, :microsecond)
      assert System.Extra.time_unit_inf(:millisecond, :nanosecond)
      assert System.Extra.time_unit_inf(:microsecond, :nanosecond)

      refute System.Extra.time_unit_inf(:second, :second)
      refute System.Extra.time_unit_inf(:millisecond, :millisecond)
      refute System.Extra.time_unit_inf(:microsecond, :microsecond)
      refute System.Extra.time_unit_inf(:nanosecond, :nanosecond)
    end

    test "nanosecond > microsecond > millisecond > second" do
      assert System.Extra.time_unit_sup(:nanosecond, :microsecond)
      assert System.Extra.time_unit_sup(:nanosecond, :millisecond)
      assert System.Extra.time_unit_sup(:nanosecond, :second)
      assert System.Extra.time_unit_sup(:microsecond, :millisecond)
      assert System.Extra.time_unit_sup(:microsecond, :second)
      assert System.Extra.time_unit_sup(:millisecond, :second)

      refute System.Extra.time_unit_sup(:nanosecond, :nanosecond)
      refute System.Extra.time_unit_sup(:microsecond, :microsecond)
      refute System.Extra.time_unit_sup(:millisecond, :millisecond)
      refute System.Extra.time_unit_sup(:second, :second)
    end
  end
end
