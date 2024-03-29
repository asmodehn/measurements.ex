defmodule MeasurementsTest do
  use ExUnit.Case
  doctest Measurements

  import Hammox

  alias Measurements.Timestamp

  alias Measurements.System
  alias Measurements.Node

  alias Measurements.Value

  describe "time/2 " do
    test "create a time measurement" do
      assert Measurements.time(51, :millisecond) == %Measurements.Value{
               value: 51,
               unit: :millisecond
             }
    end

    test "refuses units that are not related to time" do
      assert_raise(ArgumentError, fn -> Measurements.time(33, :meter) end)
    end

    test "supports extra argument for error" do
      assert Measurements.time(51, :millisecond, 3) == %Measurements.Value{
               value: 51,
               unit: :millisecond,
               error: 3
             }
    end
  end

  describe "length/2 " do
    test "create a length measurement" do
      assert Measurements.length(51, :millimeter) == %Measurements.Value{
               value: 51,
               unit: :millimeter
             }
    end

    test "refuses units that are not related to length" do
      assert_raise(ArgumentError, fn -> Measurements.length(33, :second) end)
    end

    test "supports extra argument for error" do
      assert Measurements.length(51, :millimeter, 4) == %Measurements.Value{
               value: 51,
               unit: :millimeter,
               error: 4
             }
    end
  end

  describe "sum/2" do
    test "sums two measurements of same dimension" do
      assert Measurements.time(42, :second)
             |> Measurements.sum(Measurements.time(51, :second)) == %Measurements.Value{
               value: 42 + 51,
               unit: :second
             }
    end

    test "sums two measurements with error propagation" do
      assert Measurements.time(42, :second, 3)
             |> Measurements.sum(Measurements.time(51, :second, 4)) == %Measurements.Value{
               value: 42 + 51,
               unit: :second,
               error: 4 + 3
             }
    end

    test "sums two measurements with conversion to best unit" do
      assert Measurements.time(42_000, :millisecond, 3)
             |> Measurements.sum(Measurements.time(51, :second, 4)) == %Measurements.Value{
               value: 42_000 + 51_000,
               unit: :millisecond,
               error: 4_000 + 3
             }
    end

    test "prevent sums of two measurements of units with different dimension" do
      assert_raise(ArgumentError, fn ->
        Measurements.time(42, :second)
        |> Measurements.sum(Measurements.length(51, :meter))
      end)
    end

    test "sums two timestamps as a time value" do
      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 42 end)
      |> expect(:time_offset, fn :millisecond -> 3 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s1 = Timestamp.now(:millisecond)

      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 51 end)
      |> expect(:time_offset, fn :millisecond -> 5 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s2 = Timestamp.now(:millisecond)

      assert Timestamp.system_time(s2) == %Measurements.Value{
               value: 56,
               unit: :millisecond,
               error: 0
             }

      assert Timestamp.system_time(s1) == %Measurements.Value{
               value: 45,
               unit: :millisecond,
               error: 0
             }

      assert Measurements.sum(s2, s1) == %Measurements.Value{
               value: 101,
               unit: :millisecond,
               error: 0
             }

      # Measurement sum is a Value ! Not a timestamp any more...
      # %Timestamp{
      #          node: :nonode@A,
      #          unit: :millisecond,
      #          monotonic: 42 + 51,
      #          # the average of offsets
      #          vm_offset: 4,
      #          # the delta of offsets
      #          error: 2
      #        }
    end

    test "sums a timestamp and a time value" do
      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 42 end)
      |> expect(:time_offset, fn :millisecond -> 3 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s1 = Timestamp.now(:millisecond)

      s2 = Measurements.time(51, :second, 7)

      assert Measurements.sum(s1, s2) == %Value{
               unit: :millisecond,
               value: 42 + 3 + 51_000,
               error: 7_000
             }
    end

    test "sums a time value and a timestamp" do
      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 42 end)
      |> expect(:time_offset, fn :millisecond -> 3 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s1 = Timestamp.now(:millisecond)

      s2 = Measurements.time(51, :second, 7)

      assert Measurements.sum(s2, s1) == %Value{
               unit: :millisecond,
               value: 42 + 3 + 51_000,
               error: 7_000
             }
    end
  end

  describe "delta/2" do
    test "compute the difference of two measurements of same dimension" do
      assert Measurements.time(42, :second)
             |> Measurements.delta(Measurements.time(51, :second)) == %Measurements.Value{
               value: 42 - 51,
               unit: :second
             }
    end

    test "compute the difference of two measurements with error propagation" do
      assert Measurements.time(42, :second, 3)
             |> Measurements.delta(Measurements.time(51, :second, 4)) == %Measurements.Value{
               value: 42 - 51,
               unit: :second,
               # CAREFUL : error is added
               error: 4 + 3
             }
    end

    test "compute the difference of two measurements with conversion to best unit" do
      assert Measurements.time(42_000, :millisecond, 3)
             |> Measurements.delta(Measurements.time(51, :second, 4)) == %Measurements.Value{
               value: 42_000 - 51_000,
               unit: :millisecond,
               error: 4_000 + 3
             }
    end

    test "prevent computing the difference of of two measurements of units with different dimension" do
      assert_raise(ArgumentError, fn ->
        Measurements.time(42, :second)
        |> Measurements.delta(Measurements.length(51, :meter))
      end)
    end
  end

  describe "scale/2" do
    test "scale a measurement by an integer" do
      assert Measurements.time(42, :second) |> Measurements.scale(10) == %Measurements.Value{
               value: 420,
               unit: :second
             }
    end

    test "scale a measurement with the associated error" do
      assert Measurements.time(42_000, :millisecond, 3)
             |> Measurements.scale(10) == %Measurements.Value{
               value: 420_000,
               unit: :millisecond,
               error: 30
             }
    end
  end

  describe "ratio/2" do
    test "compute the ratio of two measurements of same dimension" do
      assert Measurements.time(300, :second)
             |> Measurements.ratio(Measurements.time(60, :second)) == %Measurements.Value{
               value: 5,
               unit: nil
             }
    end

    test "compute the ratio of two measurements with error propagation" do
      assert Measurements.time(300, :second, 3)
             |> Measurements.ratio(Measurements.time(60, :second)) == %Measurements.Value{
               value: 5,
               unit: nil,
               # CAREFUL : error is relative to the value
               error: 5 * 3 / 300
             }
    end

    test "compute the ratio of two measurements with conversion to best unit" do
      assert Measurements.time(300_000, :millisecond, 3)
             |> Measurements.ratio(Measurements.time(60, :second)) == %Measurements.Value{
               value: 5,
               unit: nil,
               # CAREFUL with scale here !
               error: 5 * 3 / 300_000
             }
    end

    test "prevent computing the ratio of of two measurements of units with different dimension" do
      assert_raise(ArgumentError, fn ->
        Measurements.time(42, :second)
        |> Measurements.ratio(Measurements.length(51, :meter))
      end)
    end
  end

  describe "String.Chars protocol" do
    test "provides nice output in string" do
      assert "#{Measurements.time(42, :second)}" == "42 s"
    end

    test "provides nice output with error in string" do
      m = Measurements.time(42_000, :microsecond, 35)

      assert "#{m}" == "42000 ±35 μs"
    end
  end
end
