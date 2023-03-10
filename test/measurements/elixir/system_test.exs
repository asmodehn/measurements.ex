defmodule Measurements.SystemTest do
  use ExUnit.Case, async: true
  doctest Measurements.System

  alias Measurements.System

  import Hammox
  use Hammox.Protect, module: System, behaviour: System.OriginalBehaviour

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "System.system_time/1" do
    test "is the sum of System.monotonic_time/1 and System.time_offset/1" do
      System.OriginalMock
      |> expect(:monotonic_time, 5, fn
        :second -> 42
        :millisecond -> 42_000
        :microsecond -> 42_000_000
        :nanosecond -> 42_000_000_000
        # per second
        60 -> 42 * 60
      end)
      |> expect(:time_offset, 5, fn
        :second -> -42
        :millisecond -> -42_000
        :microsecond -> -42_000_000
        :nanosecond -> -42_000_000_000
        60 -> -42 * 60
      end)

      assert System.system_time(:second) == 0
      assert System.system_time(:millisecond) == 0
      assert System.system_time(:microsecond) == 0
      assert System.system_time(:nanosecond) == 0
      assert System.system_time(60) == 0
    end

    # TODO : test should be "close enough to Elixir's System.system_time" HOW ??
  end

  describe "System.monotonic_time/1" do
    test "returns Elixir's System.monotonic_time/1 for non-native units" do
      System.OriginalMock
      |> expect(:monotonic_time, 5, fn
        :second -> 42
        :millisecond -> 42_000
        :microsecond -> 42_000_000
        :nanosecond -> 42_000_000_000
        # per second
        60 -> 42 * 60
      end)

      assert System.monotonic_time(:second) == 42
      assert System.monotonic_time(:millisecond) == 42_000
      assert System.monotonic_time(:microsecond) == 42_000_000
      assert System.monotonic_time(:nanosecond) == 42_000_000_000
      assert System.monotonic_time(60) == 42 * 60
    end

    test "immediately rejects native or unknown units, without calling original module" do
      assert_raise(ArgumentError, fn ->
        System.monotonic_time(:native)
      end)

      assert_raise(ArgumentError, fn ->
        System.monotonic_time(:unknown)
      end)
    end
  end

  describe "XestClock's time_offset/1" do
    test "is the same as Elixir's time_offset/1 for non-native units" do
      System.OriginalMock
      |> expect(:time_offset, 5, fn
        :second -> -42
        :millisecond -> -42_000
        :microsecond -> -42_000_000
        :nanosecond -> -42_000_000_000
        60 -> -42 * 60
      end)

      assert System.time_offset(:second) == -42
      assert System.time_offset(:millisecond) == -42_000
      assert System.time_offset(:microsecond) == -42_000_000
      assert System.time_offset(:nanosecond) == -42_000_000_000
      assert System.time_offset(60) == -42 * 60
    end

    test "immediately rejects native or unknown units, without calling original module" do
      assert_raise(ArgumentError, fn ->
        System.time_offset(:native)
      end)

      assert_raise(ArgumentError, fn ->
        System.time_offset(:unknown)
      end)
    end
  end

  describe "XestClock's native_time_unit/0" do
    test "returns a time_unit that can be mocked" do
      System.ExtraMock
      |> expect(:native_time_unit, 1, fn -> :second end)

      assert System.native_time_unit() == :second
    end
  end

  describe "XestClock's convert_time_unit" do
    test "behaves the same as Elixir's convert_time_unit for non-native units" do
      assert System.convert_time_unit(1, :second, :second) ==
               System.convert_time_unit(1, :second, :second)

      assert System.convert_time_unit(1, :second, :millisecond) ==
               System.convert_time_unit(1, :second, :millisecond)

      assert System.convert_time_unit(1, :second, :microsecond) ==
               System.convert_time_unit(1, :second, :microsecond)

      assert System.convert_time_unit(1, :second, :nanosecond) ==
               System.convert_time_unit(1, :second, :nanosecond)

      assert System.convert_time_unit(1, :millisecond, :second) ==
               System.convert_time_unit(1, :millisecond, :second)

      assert System.convert_time_unit(1, :millisecond, :millisecond) ==
               System.convert_time_unit(1, :millisecond, :millisecond)

      assert System.convert_time_unit(1, :millisecond, :microsecond) ==
               System.convert_time_unit(1, :millisecond, :microsecond)

      assert System.convert_time_unit(1, :millisecond, :nanosecond) ==
               System.convert_time_unit(1, :millisecond, :nanosecond)

      assert System.convert_time_unit(1, :microsecond, :second) ==
               System.convert_time_unit(1, :microsecond, :second)

      assert System.convert_time_unit(1, :microsecond, :millisecond) ==
               System.convert_time_unit(1, :microsecond, :millisecond)

      assert System.convert_time_unit(1, :microsecond, :microsecond) ==
               System.convert_time_unit(1, :microsecond, :microsecond)

      assert System.convert_time_unit(1, :microsecond, :nanosecond) ==
               System.convert_time_unit(1, :microsecond, :nanosecond)

      assert System.convert_time_unit(1, :nanosecond, :second) ==
               System.convert_time_unit(1, :nanosecond, :second)

      assert System.convert_time_unit(1, :nanosecond, :millisecond) ==
               System.convert_time_unit(1, :nanosecond, :millisecond)

      assert System.convert_time_unit(1, :nanosecond, :microsecond) ==
               System.convert_time_unit(1, :nanosecond, :microsecond)

      assert System.convert_time_unit(1, :nanosecond, :nanosecond) ==
               System.convert_time_unit(1, :nanosecond, :nanosecond)
    end

    test "immediately rejects native or unknown units, without calling original module" do
      assert_raise(ArgumentError, fn ->
        System.convert_time_unit(1, :native, :second)
      end)

      assert_raise(ArgumentError, fn ->
        System.convert_time_unit(1, :second, :native)
      end)

      assert_raise(ArgumentError, fn ->
        System.convert_time_unit(1, :unknown, :second)
      end)

      assert_raise(ArgumentError, fn ->
        System.convert_time_unit(1, :second, :unknown)
      end)
    end
  end
end
