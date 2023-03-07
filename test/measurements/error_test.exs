defmodule Measurements.ErrorTest do
  use ExUnit.Case
  doctest Measurements.Error

  alias Measurements.Error

  describe "new/2" do
    test "build an error structure" do
      assert Error.new(33, :micrometer) == %Error{error: 33, unit: :micrometer}
      assert Error.new(42, :millisecond) == %Error{error: 42, unit: :millisecond}
    end

    test "supports aliases" do
      assert Error.new(33, :micrometers) == %Error{error: 33, unit: :micrometer}
      assert Error.new(42, :milliseconds) == %Error{error: 42, unit: :millisecond}
    end
  end

  describe "convert/2" do
    test "converts if the unit precision is greater than current one" do
      assert Error.new(42, :millisecond)
             |> Error.convert(:microsecond) == %Error{
               error: 42_000,
               unit: :microsecond
             }
    end

    test "doesn't do anything if precision is less than current one" do
      assert Error.new(42, :millisecond)
             |> Error.convert(:second) == %Error{
               error: 42,
               unit: :millisecond
             }
    end

    test "ignored if unit dimension is incompatible" do
      assert Error.new(42, :millisecond)
             |> Error.convert(:meter) == %Error{
               error: 42,
               unit: :millisecond
             }
    end
  end

  describe "convert/3 with extra: force parameter" do
    test "does force a unit conversion" do
      assert Error.new(42, :millisecond)
             |> Error.convert(:second, :force) == %Error{
               error: 0.042,
               unit: :second
             }
    end

    test "returns error when unit dimension is incompatible" do
      assert_raise ArgumentError, fn ->
        Error.new(42, :millisecond)
        |> Error.convert(:meter, :force)
      end
    end
  end
end
