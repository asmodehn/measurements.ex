defmodule Measurements.Unit.NoneTest do
  use ExUnit.Case
  doctest Measurements.Unit.None

  alias Measurements.Unit.None

  alias Measurements.Unit.Scale

  describe "__units/0" do
    test "list units available in this module" do
      assert None.__units() == []
    end
  end

  describe "__aliases/0" do
    test "list aliases available for the units in this module" do
      assert None.__alias(:anything_else) == nil
    end
  end

  describe "scale/1" do
    test "supports nil" do
      assert None.scale(nil) == Scale.new(0)
    end

    # TODO : generate random atom(property test) ?
    test "errors on any atom" do
      assert_raise ArgumentError, fn -> None.scale(:anything) end
    end
  end

  describe "unit/2" do
    test "supports Scale and Dimension as arguments to get meter" do
      {:ok, nil} = None.unit(Scale.new(0))

      {:error, convert, nil} = None.unit(Scale.new(7))
      assert convert.(42) == 420_000_000

      {:error, convert, nil} = None.unit(Scale.new(-7))
      assert convert.(42) == 0.000_004_2
    end
  end

  describe "to_string/1" do
    test "provides a string identifier for the length unit" do
      assert None.to_string(nil) == ""
    end
  end
end
