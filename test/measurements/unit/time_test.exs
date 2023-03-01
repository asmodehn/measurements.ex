defmodule Measurements.Unit.TimeTest do
  use ExUnit.Case
  doctest Measurements.Unit.Time

  alias Measurements.Unit.Time

  alias Measurements.Dimension
  alias Measurements.Scale

  describe "scale/1" do
    test "provide the scale of a time unit" do
      assert Time.scale(Time.second()) == Scale.new(0)
      assert Time.scale(Time.millisecond()) == Scale.new(-3)
      assert Time.scale(Time.microsecond()) == Scale.new(-6)
      assert Time.scale(Time.nanosecond()) == Scale.new(-9)

      assert Time.scale(1) == Scale.new(0)
      assert Time.scale(10) == Scale.new(-1)
      assert Time.scale(100) == Scale.new(-2)
      assert Time.scale(1000) == Scale.new(-3)

      # TODO
      # assert Time.scale(60) == Scale.new()

      assert Time.scale(Time.hertz()) == Scale.new(0)
      assert Time.scale(Time.kilohertz()) == Scale.new(3)
      assert Time.scale(Time.megahertz()) == Scale.new(6)
      assert Time.scale(Time.gigahertz()) == Scale.new(9)
    end
  end

  describe "dimension/1" do
    test "provides the dimension of a time unit" do
      assert Time.dimension(Time.second()) == Dimension.new() |> Dimension.with_time(1)
      assert Time.dimension(Time.millisecond()) == Dimension.new() |> Dimension.with_time(1)
      assert Time.dimension(Time.microsecond()) == Dimension.new() |> Dimension.with_time(1)
      assert Time.dimension(Time.nanosecond()) == Dimension.new() |> Dimension.with_time(1)

      assert Time.dimension(1) == Dimension.new() |> Dimension.with_time(1)
      assert Time.dimension(10) == Dimension.new() |> Dimension.with_time(1)
      assert Time.dimension(100) == Dimension.new() |> Dimension.with_time(1)
      assert Time.dimension(1000) == Dimension.new() |> Dimension.with_time(1)

      assert Time.dimension(Time.hertz()) == Dimension.new() |> Dimension.with_time(-1)
      assert Time.dimension(Time.kilohertz()) == Dimension.new() |> Dimension.with_time(-1)
      assert Time.dimension(Time.megahertz()) == Dimension.new() |> Dimension.with_time(-1)
      assert Time.dimension(Time.gigahertz()) == Dimension.new() |> Dimension.with_time(-1)
    end
  end

  describe "Time.new/2" do
    test "supports Scale and Dimension as arguments to get second" do
      {:ok, :second} = Time.new(Scale.new(), %Dimension{time: 1})
      {:ok, :millisecond} = Time.new(Scale.new(-3), %Dimension{time: 1})
      {:ok, :microsecond} = Time.new(Scale.new(-6), %Dimension{time: 1})
      {:ok, :nanosecond} = Time.new(Scale.new(-9), %Dimension{time: 1})

      {:error, convert, unit} = Time.new(Scale.new(7), %Dimension{time: 1})
      assert unit == :second
      assert convert.(42) == 420_000_000

      {:error, convert, unit} = Time.new(Scale.new(-7), %Dimension{time: 1})
      assert unit == :nanosecond
      assert convert.(42) == 4200
    end

    test "supports Scale and Dimension as arguments to get hertz" do
      {:ok, :hertz} = Time.new(Scale.new(), %Dimension{time: -1})
      {:ok, :kilohertz} = Time.new(Scale.new(3), %Dimension{time: -1})
      {:ok, :megahertz} = Time.new(Scale.new(6), %Dimension{time: -1})
      {:ok, :gigahertz} = Time.new(Scale.new(9), %Dimension{time: -1})

      {:error, convert, unit} = Time.new(Scale.new(7), %Dimension{time: -1})
      assert unit == :megahertz
      assert convert.(42) == 420

      {:error, convert, unit} = Time.new(Scale.new(-7), %Dimension{time: -1})
      assert unit == :hertz
      assert convert.(42) == 0.0000042
    end
  end
end