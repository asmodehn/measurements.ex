defmodule Measurements.UnitTest do
  use ExUnit.Case
  doctest Measurements.Unit

  alias Measurements.Unit

  alias Measurements.Unit.Time
  alias Measurements.Unit.Length

  describe "time/1 normalizes a unit if it represents time" do
    test "second, millisecond, microsecond, nanosecond" do
      assert Unit.time(:second) == {:ok, :second}
      assert Unit.time(:millisecond) == {:ok, :millisecond}
      assert Unit.time(:microsecond) == {:ok, :microsecond}
      assert Unit.time(:nanosecond) == {:ok, :nanosecond}
    end

    test "supports aliases" do
      assert Unit.time(:seconds) == {:ok, :second}
      assert Unit.time(:milliseconds) == {:ok, :millisecond}
      assert Unit.time(:microseconds) == {:ok, :microsecond}
      assert Unit.time(:nanoseconds) == {:ok, :nanosecond}
    end
  end

  describe "length/1 normalizes a unit if it represents length" do
    test "kilometer, meter, millimeter, micrometer, nanometer" do
      assert Unit.length(:kilometer) == {:ok, :kilometer}
      assert Unit.length(:meter) == {:ok, :meter}
      assert Unit.length(:millimeter) == {:ok, :millimeter}
      assert Unit.length(:micrometer) == {:ok, :micrometer}
      assert Unit.length(:nanometer) == {:ok, :nanometer}
    end

    test "support aliases" do
      assert Unit.length(:kilometers) == {:ok, :kilometer}
      assert Unit.length(:meters) == {:ok, :meter}
      assert Unit.length(:millimeters) == {:ok, :millimeter}
      assert Unit.length(:micrometers) == {:ok, :micrometer}
      assert Unit.length(:nanometers) == {:ok, :nanometer}
    end
  end

  describe "module/1" do
    test "determines the module to address for the unit" do
      assert {:ok, Time} == Unit.module(:microsecond)
      assert {:ok, Length} == Unit.module(:kilometer)
    end
  end

  describe "new/2" do
    test "normalizes a unit of any dimension" do
      assert Unit.new(:micrometer) == {:ok, :micrometer}
      assert Unit.new(:millisecond) == {:ok, :millisecond}
    end

    test "supports aliases" do
      assert Unit.new(:micrometers) == {:ok, :micrometer}
      assert Unit.new(:milliseconds) == {:ok, :millisecond}
    end
  end

  describe "convert/2" do
    test " returns a function to convert a value from one time unit to another" do
      {:ok, converter} = Unit.convert(:second, :millisecond)
      assert converter.(42) == 42_000
    end

    test " returns a function to convert a value from one length unit to another" do
      {:ok, converter} = Unit.convert(:meter, :millimeter)
      assert converter.(42) == 42_000
    end
  end

  describe "min/2 " do
    test "returns the unit with smaller scale / more precision for the unit" do
      assert Unit.min(:second, :microsecond) == {:ok, :microsecond}
      assert Unit.min(:meter, :micrometer) == {:ok, :micrometer}
    end
  end

  describe "max/2 " do
    test "returns the unit with bigger scale / less precision for the unit" do
      assert Unit.max(:second, :microsecond) == {:ok, :second}
      assert Unit.max(:meter, :micrometer) == {:ok, :meter}
    end
  end

  describe "to_string/1" do
    test "provides a string identifier for the unit" do
      assert Unit.to_string(:second) == "s"
      assert Unit.to_string(:millimeter) == "mm"
    end
  end
end
