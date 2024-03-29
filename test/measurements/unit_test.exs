defmodule Measurements.UnitTest do
  use ExUnit.Case
  doctest Measurements.Unit

  alias Measurements.Unit

  alias Measurements.Unit.Time
  alias Measurements.Unit.Length

  describe "time/1 normalizes a unit if it represents time" do
    @tag :thisone
    test "second, millisecond, microsecond, nanosecond" do
      assert Unit.time(:second) == {:ok, :second}
      assert Unit.time(:millisecond) == {:ok, :millisecond}
      assert Unit.time(:microsecond) == {:ok, :microsecond}
      assert Unit.time(:nanosecond) == {:ok, :nanosecond}
    end

    test "supports plural form" do
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

    test "support plural form" do
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

    test "supports nil unit" do
      assert {:ok, nil} == Unit.module(nil)
    end
  end

  describe "new/2" do
    test "normalizes a unit of any dimension" do
      assert Unit.new(:micrometer) == {:ok, :micrometer}
      assert Unit.new(:millisecond) == {:ok, :millisecond}
    end

    test "supports nil unit" do
      assert Unit.new(nil) == {:ok, nil}
    end

    test "supports plural form" do
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

    test "supports nil unit" do
      {:ok, converter} = Unit.convert(nil, nil)
      assert converter.(42) == 42
    end

    test "return :incompatible_dimension error when dimension dont match" do
      {:error, reason} = Unit.convert(:second, :millimeter)
      assert reason == :incompatible_dimension
    end
  end

  describe "min/2 " do
    test "returns the unit with smaller scale / more precision for the unit" do
      assert Unit.min(:second, :microsecond) == {:ok, :microsecond}
      assert Unit.min(:meter, :micrometer) == {:ok, :micrometer}
    end

    test "supports nil unit" do
      assert Unit.min(nil, nil) == {:ok, nil}
      assert Unit.min(nil, :second) == {:error, :incompatible_dimension}
    end

    test "return :incompatible_dimension error when dimension dont match" do
      {:error, reason} = Unit.min(:second, :millimeter)
      assert reason == :incompatible_dimension
    end
  end

  describe "max/2 " do
    test "returns the unit with bigger scale / less precision for the unit" do
      assert Unit.max(:second, :microsecond) == {:ok, :second}
      assert Unit.max(:meter, :micrometer) == {:ok, :meter}
    end

    test "supports nil unit" do
      assert Unit.max(nil, nil) == {:ok, nil}
      assert Unit.max(nil, :second) == {:error, :incompatible_dimension}
    end
  end

  describe "to_string/1" do
    test "provides a string identifier for the unit" do
      assert Unit.to_string(:second) == "s"
      assert Unit.to_string(:millimeter) == "mm"
    end

    test "supports nil unit" do
      assert Unit.to_string(nil) == ""
    end
  end

  describe "product/2" do
    test "multiplies unrelated units when possible and reorder them as usual" do
      assert Unit.product(:second, :meter) == {:ok, :meter_second}
    end

    test "multiplies related unit increasing corresponding dimension in atom" do
      assert Unit.product(:second, :second) == {:ok, :second_2}
    end

    @tag :product
    test "multiplies related unit with different scales, converting where needed" do
      {:error, convert_value, :millisecond_2} = Unit.product(:second, :millisecond)

      # we need to recover a factor of 1_000 since millisecond is squared, second has been converted to millisecond
      assert convert_value.(42) == 42_000
    end
  end

  # describe "ratio/2" do
  #   test "divides unrelated units when possible" do
  #     assert Unit.ratio(:meter, :second) == {:ok, :meter_per_second}
  #   end
  # end
end
