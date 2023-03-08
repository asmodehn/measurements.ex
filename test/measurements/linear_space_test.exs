defmodule Measurements.LinearSpaceTest do
  use ExUnit.Case
  doctest Measurements.LinearSpace

  alias Measurements.LinearSpace

  describe "scale/2" do
    test "scale an int by a scalar" do
      assert LinearSpace.scale(3, 4.0) == 12.0
    end

    test "scale a float by a scalar" do
      assert LinearSpace.scale(3.2, 4.0) == 12.8
    end
  end
end
