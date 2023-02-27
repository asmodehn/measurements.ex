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
end
