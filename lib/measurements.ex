defmodule Measurements do
  @moduledoc """
  Documentation for `Measurements`.

  A measurement is a quantity represented, by an integer, a unit and a (positive) error
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
  def time(v, unit) do
    # normalize the unit
    case Unit.time(unit) do
      {:ok, nu} ->
        %__MODULE__{value: v, unit: nu}

      {:error, conversion, nu} ->
        %__MODULE__{value: conversion.(v), unit: nu}
    end
  end

  @doc """
  Add error to a Measurement.
  The error is symmetric and always represented by a positive number
  The measurement unit is converted if needed to not loose precision.

  ## Examples

      iex> Measurements.time(42, :second) |> Measurements.with_error(-4, :millisecond)
      %Measurements{
        value: 42_000,
        unit: :millisecond,
        error: 4
      }

  """
  @spec with_error(t(), integer, Unit.t()) :: t
  def with_error(%__MODULE__{} = value, err, unit) when value.unit == unit do
    %{value | error: abs(err)}
  end

  def with_error(%__MODULE__{} = value, err, unit) do
    case Unit.convert(value.unit, unit) do
      {:ok, converter} ->
        %__MODULE__{
          value: converter.(value.value),
          unit: unit
        }
        |> with_error(err, unit)

      {:error, reason} ->
        raise reason
        # time(Unit.convert(same, unit), unit)
        # |> with_error(pos_int, unit)
    end
  end

  @doc """
  Convert the measurement to the unit, only if it is suitable (unit is more precise).
  Otherwise, the original measurement is returned.
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
   The sum of multiple measurements.
   Only measurements with the same unit dimension will work.
   Error will be propagated.
  """
  def sum(%__MODULE__{} = m1, %__MODULE__{} = m2) when m1.unit == m2.unit do
    %{m1 | value: m1.value + m2.value, error: m1.error + m2.error}
  end

  def sum(%__MODULE__{} = m1, %__MODULE__{} = m2) do
    m1 = best_convert(m1, m2.unit)
    m2 = best_convert(m2, m1.unit)
    sum(m1, m2)
  end
end
