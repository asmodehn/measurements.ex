defmodule MeasurementsTest do
  use ExUnit.Case
  doctest Measurements

  describe "time/2 " do
    test "create a time measurement" do
      assert Measurements.time(51, :millisecond) == %Measurements{
               value: 51,
               unit: :millisecond
             }
    end

    test "refuses units that are not related to time" do
      assert_raise(ArgumentError, fn -> Measurements.time(33, :meter) end)
    end
  end

  describe "with_error/3" do
    test "allows adding error to an existing measurement, with conversion" do
      assert Measurements.time(51, :millisecond)
             |> Measurements.with_error(33, :microsecond) == %Measurements{
               value: 51_000,
               unit: :microsecond,
               error: 33
             }
    end

    test "adds negative errors as positive, with conversion" do
      assert Measurements.time(51, :millisecond)
             |> Measurements.with_error(-33, :microsecond) == %Measurements{
               value: 51_000,
               unit: :microsecond,
               error: 33
             }
    end
  end

  describe "best_convert/2" do
    test "converts if the unit precision is greater than current one" do
      assert Measurements.time(42, :millisecond)
             |> Measurements.best_convert(:microsecond) == %Measurements{
               value: 42_000,
               unit: :microsecond
             }
    end

    test "doesnt do anything if precision is less than current one" do
      assert Measurements.time(42, :millisecond)
             |> Measurements.best_convert(:second) == %Measurements{
               value: 42,
               unit: :millisecond
             }
    end
  end

  describe "sum/2" do
    test "sums two measurements of same dimension" do
      assert Measurements.time(42, :second)
             |> Measurements.sum(Measurements.time(51, :second)) == %Measurements{
               value: 42 + 51,
               unit: :second
             }
    end

    test "sums two measurements with error propagation" do
      assert Measurements.time(42, :second)
             |> Measurements.with_error(3, :second)
             |> Measurements.sum(
               Measurements.time(51, :second)
               |> Measurements.with_error(4, :second)
             ) == %Measurements{
               value: 42 + 51,
               unit: :second,
               error: 4 + 3
             }
    end

    test "sums two measurements with conversion to best unit" do
      assert Measurements.time(42, :second)
             |> Measurements.with_error(3, :millisecond)
             |> Measurements.sum(
               Measurements.time(51, :second)
               |> Measurements.with_error(4, :second)
             ) == %Measurements{
               value: 42_000 + 51_000,
               unit: :millisecond,
               error: 4_000 + 3
             }
    end
  end
end
