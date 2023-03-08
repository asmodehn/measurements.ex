defmodule Measurements.Additive.GroupTest do
  use ExUnit.Case
  doctest Measurements.Additive.Group

  alias Measurements.Additive.Group

  describe "inverse/1 for ints" do
    test "is the opposite value" do
      # TODO : property testing
      assert Group.inverse(42) == -42
    end
  end

  describe "delta/2 for ints" do
    test "is the difference" do
      # TODO : property testing
      assert Group.delta(51, 42) == 9
      assert Group.delta(42, 51) == -9
    end
  end

  describe "scale/2 for ints" do
    test "is the scaling of the value" do
      # TODO : property testing
      assert Group.scale(42, 3) == 126
      assert Group.scale(42, -3) == -126
    end
  end

  describe "inverse/1 for floats" do
    test "is the opposite value" do
      # TODO : property testing
      assert Group.inverse(42.0) == -42.0
    end
  end

  describe "delta/2 for floats" do
    test "is the difference" do
      # TODO : property testing
      assert Group.delta(51.0, 42.0) == 9.0
      assert Group.delta(42.0, 51.0) == -9.0
    end
  end

  describe "scale/2 for floats" do
    test "is the scaling of the value" do
      # TODO : property testing
      assert Group.scale(42.0, 3) == 126.0
      assert Group.scale(42.0, -3) == -126.0
    end
  end
end
