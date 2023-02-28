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
      with {:ok, nu } <- Unit.time(unit) do
        %__MODULE__{value: v, unit: nu }
      else
        {:error, conversion, nu} -> %__MODULE__{value: conversion.(v), unit: nu }
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
    with {:ok, converter} <- Unit.convert(value.unit, unit) do
      time(converter.(value.value), unit) |> with_error(err, unit)
    else
      {:error, reason} ->
        raise reason
        # time(Unit.convert(same, unit), unit)
        # |> with_error(pos_int, unit)
    end
  end


# TODO : sum , product, etc.




end
