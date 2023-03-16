defmodule Measurements.Value do
  @moduledoc """

  The `Value` of a measurement, represented by an integer value, a positive error, and a unit.
  """

  alias Measurements.Unit
  alias Measurements.Measurement

  @enforce_keys [:value, :unit]
  defstruct value: nil,
            unit: nil,
            error: 0

  @typedoc "Measurement Type"
  @type t :: %__MODULE__{
          value: integer,
          unit: Unit.t(),
          error: non_neg_integer
        }

  # Unneeded ??
  # @behaviour Access

  # OR ONLY PARTIAL IMPLEMENTATINON POSIBLE ??
  # @impl Access
  def fetch(%__MODULE__{} = v, key) do
    Map.fetch(v, key)
  end

  # OR maybe gather new() / add_errr() / convert() via Access protocol ?
  # OR better custom protocol ???

  # @impl Access
  # def get_and_update(%__MODULE__{} = v, key, fun) do
  #   Map.get_and_update(v, key, fun)
  # end

  # @impl Access
  # def pop(%__MODULE__{} = v, key) do
  #   Map.get_and_update(v, key, fn v -> {v, nil} end)
  # end

  @doc """
  Generic Measurements.Value. Unit indicates the dimension.

  ## Examples

      iex> Measurements.Value.new(42, :meter)
      %Measurements.Value{
        value: 42,
        unit: :meter
      }

  """
  @spec new(integer, Unit.t()) :: t
  @spec new(integer, Unit.t(), integer) :: t
  def new(v, unit, err \\ 0) do
    # normalize the unit
    case Unit.new(unit) do
      # TODO : while new/2 seems the more intuitive approach, 
      # we might need a way to pass unknown units to Unit.new/2 somehow...
      # maybe create them with time/1, length/1 ??
      {:ok, nu} ->
        %__MODULE__{value: v, unit: nu, error: abs(err)}

      {:error, conversion, nu} ->
        %__MODULE__{value: conversion.(v), unit: nu, error: abs(err)}
    end
  end

  @doc """
  Add error to a Measurements.Value.

  The error is symmetric and always represented by a positive number.
  The measurement unit is converted if needed to not loose precision.

  ## Examples

      iex> Measurements.Value.new(42, :second) |> Measurements.Value.add_error(-4, :millisecond)
      %Measurements.Value{
        value: 42_000,
        unit: :millisecond,
        error: 4
      }

  """
  @spec add_error(t(), integer, Unit.t()) :: t
  def add_error(%__MODULE__{} = value, err, unit) when value.unit == unit do
    %{value | error: value.error + abs(err)}
  end

  def add_error(%__MODULE__{} = value, err, unit) do
    case Unit.convert(value.unit, unit) do
      {:ok, converter} ->
        %__MODULE__{
          value: converter.(value.value),
          unit: unit
        }
        |> add_error(err, unit)

      {:error, reason} ->
        raise reason
        # time(Unit.convert(same, unit), unit)
        # |> with_error(pos_int, unit)
    end
  end

  def convert(%Measurements.Value{} = m, unit, :force) do
    case Unit.convert(m.unit, unit) do
      {:ok, converter} ->
        new(
          converter.(m.value),
          unit,
          converter.(m.error)
        )

      {:error, :incompatible_dimension} ->
        raise ArgumentError, message: "#{unit} dimension is not compatible with #{m.unit}"
    end
  end

  @doc """
  The sum of multiple measurements, with implicit unit conversion.

  Only measurements with the same unit dimension will work.
  Error will be propagated.

  ## Examples

      iex>  m1 = Measurements.time(42, :second) |> Measurements.Value.add_error(1, :second)
      iex>  m2 = Measurements.time(543, :millisecond) |> Measurements.Value.add_error(3, :millisecond)
      iex> Measurements.sum(m1, m2)
      %Measurements.Value{
        value: 42_543,
        unit: :millisecond,
        error: 1_003
      }

  """
  def sum(%__MODULE__{} = v1, m) do
    if v1.unit ==
         Measurement.unit(m) do
      new(
        v1.value + Measurement.value(m),
        v1.unit,
        v1.error + Measurement.error(m)
      )
    else
      with {:ok, s1} <- Unit.scale(v1.unit),
           {:ok, s2} <- Unit.scale(Measurement.unit(m)) do
        if s1.dimension == s2.dimension do
          v1 = Measurement.convert(v1, Measurement.unit(m))
          m = Measurement.convert(m, v1.unit)
          sum(v1, m)
        else
          raise ArgumentError, message: "#{v1} and #{m} have incompatible unit dimension"
        end
      end
    end
  end

  def delta(%__MODULE__{} = v1, m) do
    if v1.unit ==
         Measurement.unit(m) do
      new(
        v1.value - Measurement.value(m),
        v1.unit,
        v1.error + Measurement.error(m)
      )
    else
      with {:ok, s1} <- Unit.scale(v1.unit),
           {:ok, s2} <- Unit.scale(Measurement.unit(m)) do
        if s1.dimension == s2.dimension do
          m1 = Measurement.convert(v1, Measurement.unit(m))
          m2 = Measurement.convert(m, v1.unit)
          delta(m1, m2)
        else
          raise ArgumentError, message: "#{v1} and #{m} have incompatible unit dimension"
        end
      end
    end
  end

  @doc """
  Scales a measurement by a number.

  No unit conversion happens at this stage for simplicity, and to keep the scale of the resulting value obvious.
  Error will be scaled by the same number, but always remains positive.

  ## Examples

        iex>  m1 = Measurements.Value.new(543, :millisecond)
        iex> Measurements.Value.scale(m1, 10)
        %Measurements.Value{
          value: 5430,
          unit: :millisecond
        }

  """
  def scale(%__MODULE__{} = e, n) when is_integer(n) do
    new(e.value * n, e.unit, abs(e.error * n))
  end

  def ratio(%__MODULE__{} = v1, m) do
    if v1.unit ==
         Measurement.unit(m) do
      v1_rel_err = v1.error / v1.value
      v2_rel_err = Measurement.error(m) / Measurement.value(m)

      value =
        if rem(v1.value, Measurement.value(m)) == 0,
          do: div(v1.value, Measurement.value(m)),
          else: v1.value / Measurement.value(m)

      error = abs(value * (v1_rel_err + v2_rel_err))

      new(value, nil, error)
    else
      with {:ok, s1} <- Unit.scale(v1.unit),
           {:ok, s2} <- Unit.scale(Measurement.unit(m)) do
        if s1.dimension == s2.dimension do
          m1 = Measurement.convert(v1, Measurement.unit(m))
          m2 = Measurement.convert(m, v1.unit)
          ratio(m1, m2)
        else
          raise ArgumentError, message: "#{v1} and #{m} have incompatible unit dimension"
        end
      end
    end
  end
end

defimpl Measurements.Measurement, for: Measurements.Value do
  def value(%Measurements.Value{} = v), do: v.value

  def error(%Measurements.Value{} = v), do: v.error

  def unit(%Measurements.Value{} = v), do: v.unit

  @doc """
  Convert the measurement to the new unit, if the new unit is more precise.

  This will pick the most precise between the measurement's unit and the new unit.
  Then it will convert the measurement to the chosen unit.

  If no conversion is possible, the original measurement is returned.

  ## Examples

      iex> Measurements.Value.new(42, :second) |> Measurements.Value.add_error(1, :second) |> Measurements.Value.convert(:millisecond)
      %Measurements.Value{value: 42_000, unit: :millisecond, error: 1_000}

      iex> Measurements.Value.new(42, :millisecond) |> Measurements.Value.add_error(1, :millisecond) |> Measurements.Value.convert(:second)
      %Measurements.Value{value: 42, unit: :millisecond, error: 1}

  """
  @spec convert(Measurements.Value.t(), Measurements.Unit.t()) :: Measurements.Value.t()

  def convert(%Measurements.Value{unit: u} = m, unit) when u == unit, do: m

  def convert(%Measurements.Value{} = m, unit) do
    case Measurements.Unit.min(m.unit, unit) do
      {:ok, min_unit} ->
        # if Unit.min is successful, conversion will always work.
        Measurements.Value.convert(m, min_unit, :force)

      # no conversion possible, just ignore it
      {:error, :incompatible_dimension} ->
        m
    end
  end
end

defimpl String.Chars, for: Measurements.Value do
  def to_string(%Measurements.Value{
        value: v,
        unit: unit,
        error: 0
      }) do
    u = Measurements.Unit.to_string(unit)

    "#{v} #{u}"
  end

  def to_string(%Measurements.Value{
        value: v,
        unit: unit,
        error: err
      }) do
    u = Measurements.Unit.to_string(unit)

    "#{v} ±#{err} #{u}"
  end
end
