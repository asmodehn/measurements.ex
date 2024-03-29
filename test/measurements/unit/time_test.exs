defmodule Measurements.Unit.TimeTest do
  use ExUnit.Case
  doctest Measurements.Unit.Time

  alias Measurements.Unit.Time

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Scale

  describe "__units/0" do
    test "list units available in this module" do
      assert :second in Time.__units()
      assert :millisecond in Time.__units()
      assert :microsecond in Time.__units()
      assert :nanosecond in Time.__units()

      # assert :hertz in Time.__units()
      # assert :kilohertz in Time.__units()
      # assert :megahertz in Time.__units()
      # assert :gigahertz in Time.__units()
    end
  end

  describe "__aliases/0" do
    test "list aliases available for the units in this module" do
      assert Time.__alias(:seconds) == :second
      assert Time.__alias(:milliseconds) == :millisecond
      assert Time.__alias(:microseconds) == :microsecond
      assert Time.__alias(:nanoseconds) == :nanosecond
    end
  end

  describe "scale/1" do
    test "provide the scale of a time unit" do
      assert Time.scale(Time.second()) == %{
               Scale.new(0)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(Time.millisecond()) == %{
               Scale.new(-3)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(Time.microsecond()) == %{
               Scale.new(-6)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(Time.nanosecond()) == %{
               Scale.new(-9)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      # TODO : verify is it this dimension or opposite ??
      assert Time.scale(1) == %{
               Scale.new(0)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(10) == %{
               Scale.new(-1)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(100) == %{
               Scale.new(-2)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(1000) == %{
               Scale.new(-3)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(60) == %{
               Scale.new(-1, 6)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      # # inverse dimension -> inverse scale !
      # assert Time.scale(Time.hertz()) == %{
      #          Scale.new(0)
      #          | dimension: Dimension.new() |> Dimension.with_time(-1)
      #        }

      # assert Time.scale(Time.kilohertz()) == %{
      #          Scale.new(3)
      #          | dimension: Dimension.new() |> Dimension.with_time(-1)
      #        }

      # assert Time.scale(Time.megahertz()) == %{
      #          Scale.new(6)
      #          | dimension: Dimension.new() |> Dimension.with_time(-1)
      #        }

      # assert Time.scale(Time.gigahertz()) == %{
      #          Scale.new(9)
      #          | dimension: Dimension.new() |> Dimension.with_time(-1)
      #        }
    end

    test "supports nil" do
      assert Time.scale(nil) == Scale.new(0)
    end

    test "supports aliases" do
      assert Time.scale(:seconds) == %{
               Scale.new(0)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(:milliseconds) == %{
               Scale.new(-3)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(:microseconds) == %{
               Scale.new(-6)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }

      assert Time.scale(:nanoseconds) == %{
               Scale.new(-9)
               | dimension: Dimension.new() |> Dimension.with_time(1)
             }
    end
  end

  describe "unit/2" do
    @tag :second
    test "supports Scale and Dimension as arguments to get second" do
      {:ok, :second} =
        Time.unit(%{Scale.new(0) | dimension: Dimension.new() |> Dimension.with_time(1)})

      {:ok, :millisecond} =
        Time.unit(%{Scale.new(-3) | dimension: Dimension.new() |> Dimension.with_time(1)})

      {:ok, :microsecond} =
        Time.unit(%{Scale.new(-6) | dimension: Dimension.new() |> Dimension.with_time(1)})

      {:ok, :nanosecond} =
        Time.unit(%{Scale.new(-9) | dimension: Dimension.new() |> Dimension.with_time(1)})

      {:error, convert, unit} =
        Time.unit(%{Scale.new(7) | dimension: Dimension.new() |> Dimension.with_time(1)})

      assert unit == :second
      assert convert.(42) == 420_000_000

      {:error, convert, unit} =
        Time.unit(%{Scale.new(-7) | dimension: Dimension.new() |> Dimension.with_time(1)})

      assert unit == :nanosecond
      assert convert.(42) == 4200
    end

    # @tag :hertz
    # test "supports Scale and Dimension as arguments to get hertz" do
    #   {:ok, :hertz} =
    #     Time.unit(%{Scale.new(0) | dimension: Dimension.new() |> Dimension.with_time(-1)})

    #   {:ok, :kilohertz} =
    #     Time.unit(%{Scale.new(3) | dimension: Dimension.new() |> Dimension.with_time(-1)})

    #   {:ok, :megahertz} =
    #     Time.unit(%{Scale.new(6) | dimension: Dimension.new() |> Dimension.with_time(-1)})

    #   {:ok, :gigahertz} =
    #     Time.unit(%{Scale.new(9) | dimension: Dimension.new() |> Dimension.with_time(-1)})

    #   {:error, convert, unit} =
    #     Time.unit(%{Scale.new(7) | dimension: Dimension.new() |> Dimension.with_time(-1)})

    #   assert unit == :megahertz
    #   assert convert.(42) == 420

    #   # |> IO.inspect()
    #   {:error, convert, unit} =
    #     Time.unit(%{Scale.new(-7) | dimension: Dimension.new() |> Dimension.with_time(-1)})

    #   assert unit == :hertz
    #   # Note : round is needed because scale conversion may produce imprecise float...
    #   # HOW to fix that ?? -> define a more precise unit, ie. `:nanohertz` in the Appropriate `Time` module.
    #   assert Float.round(convert.(42), 7) == 0.0000042
    # end
  end

  describe "to_string/1" do
    test "provides a string identifier for the time unit" do
      assert Time.to_string(:second) == "s"
      assert Time.to_string(:millisecond) == "ms"
      assert Time.to_string(:microsecond) == "μs"
      assert Time.to_string(:nanosecond) == "ns"
    end
  end
end
