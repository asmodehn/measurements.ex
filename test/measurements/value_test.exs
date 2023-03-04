defmodule Measurements.ValueTest do
  use ExUnit.Case
  doctest Measurements.Value

  alias Measurements.Value

  describe "new/2" do
    test "build any type of measurement" do
      assert Value.new(33, :micrometer) == %Value{value: 33, unit: :micrometer}
      assert Value.new(42, :millisecond) == %Value{value: 42, unit: :millisecond}
    end

    test "supports aliases" do
      assert Value.new(33, :micrometers) == %Value{value: 33, unit: :micrometer}
      assert Value.new(42, :milliseconds) == %Value{value: 42, unit: :millisecond}
    end

    test "supports extra argument for errors" do
      assert Value.new(33, :micrometer, 3) == %Value{
               value: 33,
               unit: :micrometer,
               error: 3
             }

      assert Value.new(42, :millisecond, 2) == %Value{
               value: 42,
               unit: :millisecond,
               error: 2
             }
    end
  end

  describe "add_error/3" do
    test "allows adding error to an existing measurement, with conversion" do
      assert Value.new(51, :millisecond)
             |> Value.add_error(33, :microsecond) == %Value{
               value: 51_000,
               unit: :microsecond,
               error: 33
             }
    end

    test "adds negative errors as positive, with conversion" do
      assert Value.new(51, :millisecond)
             |> Value.add_error(-33, :microsecond) == %Value{
               value: 51_000,
               unit: :microsecond,
               error: 33
             }
    end
  end

  describe "best_convert/2" do
    test "converts if the unit precision is greater than current one" do
      assert Value.new(42, :millisecond)
             |> Value.best_convert(:microsecond) == %Value{
               value: 42_000,
               unit: :microsecond
             }
    end

    test "doesnt do anything if precision is less than current one" do
      assert Value.new(42, :millisecond)
             |> Value.best_convert(:second) == %Value{
               value: 42,
               unit: :millisecond
             }
    end
  end

  describe "Access protocol: " do
    test "fetch/2 implemented" do
      v = Value.new(51, :millisecond, 33)
      assert Value.fetch(v, :value) == {:ok, 51}
      assert Value.fetch(v, :error) == {:ok, 33}
      assert Value.fetch(v, :unit) == {:ok, :millisecond}
    end

    test "get_and_update/3 implemented" do
      v = Value.new(51, :millisecond, 33)

      assert Value.get_and_update(v, :value, fn n -> {n, n - 9} end) ==
               {51, %Measurements.Value{value: 42, unit: :millisecond, error: 33}}

      assert Value.get_and_update(v, :error, fn n -> {n, n + 9} end) ==
               {33, %Measurements.Value{value: 51, unit: :millisecond, error: 42}}

      assert Value.get_and_update(v, :unit, fn :millisecond -> {:millisecond, :microsecond} end) ==
               {:millisecond, %Measurements.Value{value: 51, unit: :microsecond, error: 33}}
    end

    test "pop/2 implemented by setting field to nil" do
      v = Value.new(51, :millisecond, 33)
      assert Value.pop(v, :value) == {51, %Value{value: nil, unit: :millisecond, error: 33}}
      assert Value.pop(v, :error) == {33, %Value{value: 51, unit: :millisecond, error: nil}}
      assert Value.pop(v, :unit) == {:millisecond, %Value{value: 51, unit: nil, error: 33}}
    end
  end
end
