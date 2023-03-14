defmodule Measurements.Unit.LengthTest do
  use ExUnit.Case
  doctest Measurements.Unit.Length

  alias Measurements.Unit.Length

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Scale

  describe "__units/0" do
    test "list units available in this module" do
      assert :kilometer in Length.__units()
      assert :meter in Length.__units()
      assert :millimeter in Length.__units()
      assert :micrometer in Length.__units()
      assert :nanometer in Length.__units()
    end
  end

  describe "__aliases/0" do
    test "list aliases available for the units in this module" do
      assert Length.__alias(:kilometers) == :kilometer
      assert Length.__alias(:meters) == :meter
      assert Length.__alias(:millimeters) == :millimeter
      assert Length.__alias(:micrometers) == :micrometer
      assert Length.__alias(:nanometers) == :nanometer
    end
  end

  describe "scale/1" do
    test "provide the scale of a length unit" do
      assert Length.scale(Length.kilometer()) == %{
               Scale.new(3)
               | dimension: %Dimension{length: 1}
             }

      assert Length.scale(Length.meter()) == %{Scale.new(0) | dimension: %Dimension{length: 1}}

      assert Length.scale(Length.millimeter()) == %{
               Scale.new(-3)
               | dimension: %Dimension{length: 1}
             }

      assert Length.scale(Length.micrometer()) == %{
               Scale.new(-6)
               | dimension: %Dimension{length: 1}
             }

      assert Length.scale(Length.nanometer()) == %{
               Scale.new(-9)
               | dimension: %Dimension{length: 1}
             }
    end

    test "supports nil" do
      assert Length.scale(nil) == Scale.new(0)
    end

    test " supports aliases" do
      assert Length.scale(:kilometers) == %{Scale.new(3) | dimension: %Dimension{length: 1}}
      assert Length.scale(:meters) == %{Scale.new(0) | dimension: %Dimension{length: 1}}
      assert Length.scale(:millimeters) == %{Scale.new(-3) | dimension: %Dimension{length: 1}}
      assert Length.scale(:micrometers) == %{Scale.new(-6) | dimension: %Dimension{length: 1}}
      assert Length.scale(:nanometers) == %{Scale.new(-9) | dimension: %Dimension{length: 1}}
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

    test "supports nil" do
      assert Length.dimension(nil) == %Dimension{}
    end

    test " supports aliases" do
      assert Length.dimension(:kilometers) == %Dimension{length: 1}
      assert Length.dimension(:meters) == %Dimension{length: 1}
      assert Length.dimension(:millimeters) == %Dimension{length: 1}
      assert Length.dimension(:micrometers) == %Dimension{length: 1}
      assert Length.dimension(:nanometers) == %Dimension{length: 1}
    end
  end

  describe "unit/2" do
    @tag :meter
    test "supports Scale and Dimension as arguments to get meter" do
      {:ok, :kilometer} = Length.unit(%{Scale.new(3) | dimension: %Dimension{length: 1}})
      {:ok, :meter} = Length.unit(%{Scale.new(0) | dimension: %Dimension{length: 1}})
      {:ok, :millimeter} = Length.unit(%{Scale.new(-3) | dimension: %Dimension{length: 1}})
      {:ok, :micrometer} = Length.unit(%{Scale.new(-6) | dimension: %Dimension{length: 1}})
      {:ok, :nanometer} = Length.unit(%{Scale.new(-9) | dimension: %Dimension{length: 1}})

      {:error, convert, unit} = Length.unit(%{Scale.new(7) | dimension: %Dimension{length: 1}})
      assert unit == :kilometer
      assert convert.(42) == 420_000

      {:error, convert, unit} = Length.unit(%{Scale.new(-7) | dimension: %Dimension{length: 1}})
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
