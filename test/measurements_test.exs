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

  describe "length/2 " do
    test "create a length measurement" do
      assert Measurements.length(51, :millimeter) == %Measurements{
               value: 51,
               unit: :millimeter
             }
    end

    test "refuses units that are not related to length" do
      assert_raise(ArgumentError, fn -> Measurements.length(33, :second) end)
    end
  end

  describe "new/2" do
    test "build any type of measurement" do
      assert Measurements.new(33, :micrometer) == %Measurements{value: 33, unit: :micrometer}
      assert Measurements.new(42, :millisecond) == %Measurements{value: 42, unit: :millisecond}
    end

    test "supports aliases" do
      assert Measurements.new(33, :micrometers) == %Measurements{value: 33, unit: :micrometer}
      assert Measurements.new(42, :milliseconds) == %Measurements{value: 42, unit: :millisecond}
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

  describe "scale/2" do
    test "scale a measurement by an integer" do
      assert Measurements.time(42, :second) |> Measurements.scale(10) == %Measurements{
               value: 420,
               unit: :second
             }
    end

    test "scale a measurement with the associated error" do
      assert Measurements.time(42, :second)
             |> Measurements.with_error(3, :millisecond)
             |> Measurements.scale(10) == %Measurements{
               value: 420_000,
               unit: :millisecond,
               error: 30
             }
    end
  end

  describe "String.Chars protocol" do
    test "provides nice output in string" do
      assert "#{Measurements.time(42, :second)}" == "42 s"
    end

    test "provides nice output with error in string" do
      m =
        Measurements.time(42, :millisecond)
        |> Measurements.with_error(35, :microsecond)

      assert "#{m}" == "42000 ±35 μs"
    end
  end
end
