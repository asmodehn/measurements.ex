defmodule Measurements.Unit.LengthTest do
  use ExUnit.Case
  doctest Measurements.Unit.Length

  alias Measurements.Unit.Length

  alias Measurements.Dimension
  alias Measurements.Scale

  describe "scale/1" do
    test "provide the scale of a length unit" do
      assert Length.scale(Length.kilometer()) == Scale.new(3)
      assert Length.scale(Length.meter()) == Scale.new(0)
      assert Length.scale(Length.millimeter()) == Scale.new(-3)
      assert Length.scale(Length.micrometer()) == Scale.new(-6)
      assert Length.scale(Length.nanometer()) == Scale.new(-9)
    end
  end

  describe "dimension/1" do
    test "provides the dimension of a length unit" do
      assert Length.dimension(Length.kilometer()) == Dimension.new() |> Dimension.with_length(1)
      assert Length.dimension(Length.meter()) == Dimension.new() |> Dimension.with_length(1)
      assert Length.dimension(Length.millimeter()) == Dimension.new() |> Dimension.with_length(1)
      assert Length.dimension(Length.micrometer()) == Dimension.new() |> Dimension.with_length(1)
      assert Length.dimension(Length.nanometer()) == Dimension.new() |> Dimension.with_length(1)
    end
  end

  describe "new/2" do
    test "supports Scale and Dimension as arguments to get meter" do
      {:ok, :kilometer} = Length.new(Scale.new(3), %Dimension{length: 1})
      {:ok, :meter} = Length.new(Scale.new(0), %Dimension{length: 1})
      {:ok, :millimeter} = Length.new(Scale.new(-3), %Dimension{length: 1})
      {:ok, :micrometer} = Length.new(Scale.new(-6), %Dimension{length: 1})
      {:ok, :nanometer} = Length.new(Scale.new(-9), %Dimension{length: 1})

      {:error, convert, unit} = Length.new(Scale.new(7), %Dimension{length: 1})
      assert unit == :kilometer
      assert convert.(42) == 420_000

      {:error, convert, unit} = Length.new(Scale.new(-7), %Dimension{length: 1})
      assert unit == :nanometer
      assert convert.(42) == 4200
    end
  end

  describe "to_string/1" do
    test "provides a string identifier for the length unit" do
      assert Length.to_string(:kilometer) == "km"
      assert Length.to_string(:meter) == "m"
      assert Length.to_string(:millimeter) == "mm"
      assert Length.to_string(:micrometer) == "μm"
      assert Length.to_string(:nanometer) == "nm"
    end
  end
end
