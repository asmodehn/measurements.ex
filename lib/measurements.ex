defmodule Measurements do
  @moduledoc """
  Documentation for `Measurements`.

  A measurement is a quantity represented, by a value, a unit and an error.

  The value is usually an integer to maintain maximum precision,
  but can also be a float if required.

  ## Examples

      iex> Measurements.time(42, :second)
      %Measurements{
        value: 42,
        unit: :second,
        error: 0
      }
  """

  alias Measurements.Unit

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

  @doc """
  Time Measurement.

  ## Examples

      iex> Measurements.time(42, :second)
      %Measurements{
        value: 42,
        unit: :second
      }

  """
  @spec time(integer, Unit.t()) :: t
  @spec time(integer, Unit.t(), integer) :: t
  def time(v, unit, err \\ 0) do
    # normalize the unit
    case Unit.time(unit) do
      {:ok, nu} ->
        %__MODULE__{value: v, unit: nu, error: abs(err)}

      {:error, conversion, nu} ->
        %__MODULE__{value: conversion.(v), unit: nu, error: abs(err)}

      {:error, :not_a_supported_time_unit} ->
        raise ArgumentError, message: "#{unit} is not a supported time unit"
    end
  end

  @doc """
  Length Measurement.

  ## Examples

      iex> Measurements.length(42, :meter)
      %Measurements{
        value: 42,
        unit: :meter
      }

  """
  @spec length(integer, Unit.t()) :: t
  @spec length(integer, Unit.t(), integer) :: t
  def length(v, unit, err \\ 0) do
    # normalize the unit
    case Unit.length(unit) do
      {:ok, nu} ->
        %__MODULE__{value: v, unit: nu, error: abs(err)}

      {:error, conversion, nu} ->
        %__MODULE__{value: conversion.(v), unit: nu, error: abs(err)}

      {:error, :not_a_supported_length_unit} ->
        raise ArgumentError, message: "#{unit} is not a supported length unit"
    end
  end

  @doc """
  Generic Measurement. Unit indicates the dimension.

  ## Examples

      iex> Measurements.new(42, :meter)
      %Measurements{
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
  Add error to a Measurement.

  The error is symmetric and always represented by a positive number.
  The measurement unit is converted if needed to not loose precision.

  ## Examples

      iex> Measurements.time(42, :second) |> Measurements.add_error(-4, :millisecond)
      %Measurements{
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

  @doc """
  Convert the measurement to the new unit, if the new unit is more precise.

  This will pick the most precise between the measurement's unit and the new unit.
  Then it will convert the measurement to the chosen unit.

  If no conversion is possible, the original measurement is returned.

  ## Examples

      iex> Measurements.time(42, :second) |> Measurements.add_error(1, :second) |> Measurements.best_convert(:millisecond)
      %Measurements{value: 42_000, unit: :millisecond, error: 1_000}

      iex> Measurements.time(42, :millisecond) |> Measurements.add_error(1, :millisecond) |> Measurements.best_convert(:second)
      %Measurements{value: 42, unit: :millisecond, error: 1}

  """
  @spec best_convert(t, Unit.t()) :: t

  def best_convert(%__MODULE__{unit: u} = m, unit) when u == unit, do: m

  def best_convert(%__MODULE__{} = m, unit) do
    case Unit.min(m.unit, unit) do
      {:ok, min_unit} ->
        # if Unit.min is successful, conversion will always work.
        {:ok, converter} = Unit.convert(m.unit, min_unit)

        %__MODULE__{
          value: converter.(m.value),
          unit: min_unit,
          error: converter.(m.error)
        }

      # no conversion possible, just ignore it
      {:error, :incompatible_dimension} ->
        m
    end
  end

  @doc """
  The sum of multiple measurements, with implicit unit conversion.

  Only measurements with the same unit dimension will work.
  Error will be propagated.

  ## Examples

      iex>  m1 = Measurements.time(42, :second) |> Measurements.add_error(1, :second)
      iex>  m2 = Measurements.time(543, :millisecond) |> Measurements.add_error(3, :millisecond)
      iex> Measurements.sum(m1, m2)
      %Measurements{
        value: 42_543,
        unit: :millisecond,
        error: 1_003
      }

  """
  def sum(%__MODULE__{} = m1, %__MODULE__{} = m2) when m1.unit == m2.unit do
    %{m1 | value: m1.value + m2.value, error: m1.error + m2.error}
  end

  def sum(%__MODULE__{} = m1, %__MODULE__{} = m2) do
    if Unit.dimension(m1.unit) == Unit.dimension(m2.unit) do
      m1 = best_convert(m1, m2.unit)
      m2 = best_convert(m2, m1.unit)
      sum(m1, m2)
    else
      raise ArgumentError, message: "#{m1} and #{m2} have incompatible unit dimension"
    end
  end

  @doc """
  Scales a measurement by a number.

  No unit conversion happens at this stage for simplicity, and to keep the scale of the resulting value obvious.
  Error will be scaled by the same number, but always remains positive.

  ## Examples

        iex>  m1 = Measurements.time(543, :millisecond) |> Measurements.add_error(3, :millisecond)
        iex> Measurements.scale(m1, 10)
        %Measurements{
          value: 5430,
          unit: :millisecond,
          error: 30
        }

  """
  def scale(%__MODULE__{} = m1, n) when is_integer(n) do
    %{m1 | value: m1.value * n, error: abs(m1.error * n)}
  end

  @doc """
  The difference of two measurements, with implicit unit conversion.

  Only measurements with the same unit dimension will work.
  Error will be propagated (ie compounded).

  ## Examples

      iex>  m1 = Measurements.time(42, :second) |> Measurements.add_error(1, :second)
      iex>  m2 = Measurements.time(543, :millisecond) |> Measurements.add_error(3, :millisecond)
      iex> Measurements.delta(m1, m2)
      %Measurements{
        value: 41_457,
        unit: :millisecond,
        error: 1_003
      }

  """
  def delta(%__MODULE__{} = m1, %__MODULE__{} = m2) when m1.unit == m2.unit do
    %{m1 | value: m1.value - m2.value, error: m1.error + m2.error}
  end

  def delta(%__MODULE__{} = m1, %__MODULE__{} = m2) do
    if Unit.dimension(m1.unit) == Unit.dimension(m2.unit) do
      m1 = best_convert(m1, m2.unit)
      m2 = best_convert(m2, m1.unit)
      delta(m1, m2)
    else
      raise ArgumentError, message: "#{m1} and #{m2} have incompatible unit dimension"
    end
  end

  defimpl String.Chars, for: Measurements do
    def to_string(%Measurements{
          value: v,
          unit: unit,
          error: 0
        }) do
      u = Measurements.Unit.to_string(unit)

      "#{v} #{u}"
    end

    def to_string(%Measurements{
          value: v,
          unit: unit,
          error: err
        }) do
      u = Measurements.Unit.to_string(unit)

      "#{v} ±#{err} #{u}"
    end
  end
end
