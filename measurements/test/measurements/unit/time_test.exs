defmodule Measurements.Unit.TimeTest do
  use ExUnit.Case
  doctest Measurements.Unit.Time

  alias Measurements.Unit.Time

  # describe "Time unit new/1 supports all time units supported by Elixir.System" do
  #   test ":second, :millisecond, :microsecond, :nanosecond" do
  #     assert Time.new(:second) == :second
  #     assert Time.new(:millisecond) == :millisecond
  #     assert Time.new(:microsecond) == :microsecond
  #     assert Time.new(:nanosecond) == :nanosecond
  #   end

  #   test "positive integer for \"per second\" ie. frequency" do
  #     assert Time.new(60) == 60
  #   end
  # end

  # describe "Time unit new/1 also support invert frequency units" do
  #   test ":hertz, :kilohertz, :megahertz, :gigahertz" do
  #     assert Time.new(:hertz) == 1
  #     assert Time.new(:kilohertz) == 1_000
  #     assert Time.new(:megahertz) == 1_000_000
  #     assert Time.new(:gigahertz) == 1_000_000_000
  #   end
  # end

  # describe "Time unit new/1 errors explicitely" do
  #   test "unknown atom" do
  #     assert_raise(ArgumentError, fn -> Time.new(:something_else) end)
  #   end
  # end

  # describe "Time unit ratio/2 supports all arguments configuration" do
  #   test "second, millisecond, microsecond, nanosecond " do
  #     assert Time.ratio(:second, :millisecond) == 1_000
  #     assert Time.ratio(:second, :microsecond) == 1_000_000
  #     assert Time.ratio(:second, :nanosecond) == 1_000_000_000
  #     assert Time.ratio(:millisecond, :microsecond) == 1_000
  #     assert Time.ratio(:millisecond, :nanosecond) == 1_000_000
  #     assert Time.ratio(:microsecond, :nanosecond) == 1_000

  #     assert Time.ratio(:second, :second) == 1
  #     assert Time.ratio(:millisecond, :millisecond) == 1
  #     assert Time.ratio(:microsecond, :microsecond) == 1
  #     assert Time.ratio(:nanosecond, :nanosecond) == 1
  #   end

  #   test "hertz, kilohertz, megahertz, gigahertz " do
  #     assert Time.ratio(:kilohertz, :hertz) == 1_000
  #     assert Time.ratio(:megahertz, :hertz) == 1_000_000
  #     assert Time.ratio(:gigahertz, :hertz) == 1_000_000_000
  #     assert Time.ratio(:megahertz, :kilohertz) == 1_000
  #     assert Time.ratio(:gigahertz, :kilohertz) == 1_000_000
  #     assert Time.ratio(:gigahertz, :megahertz) == 1_000

  #     assert Time.ratio(:hertz, :hertz) == 1
  #     assert Time.ratio(:kilohertz, :kilohertz) == 1
  #     assert Time.ratio(:megahertz, :megahertz) == 1
  #     assert Time.ratio(:gigahertz, :gigahertz) == 1
  #   end

  #   test "\"per second\" ie frequency" do
  #     assert Time.ratio(:second, 10) == 10
  #     assert Time.ratio(:millisecond, 10) == 0.01
  #     assert Time.ratio(10, :second) == 0.1
  #     assert Time.ratio(10, :millisecond) == 100
  #   end

  #   test "\"per hertz\" ie period" do
  #     assert Time.ratio(10, :hertz) == 10
  #     assert Time.ratio(10, :kilohertz) == 0.01
  #     assert Time.ratio(:hertz, 10) == 0.1
  #     assert Time.ratio(:kilohertz, 10) == 100
  #   end
  # end
end
