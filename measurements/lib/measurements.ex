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
  def time(int, unit) do
    %__MODULE__{value: int, unit: Unit.time(unit)}
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
  @spec with_error(t(), non_neg_integer, Unit.t()) :: t
  def with_error(%__MODULE__{} = value, pos_int, unit) when value.unit == unit do
    %{value | error: abs(pos_int)}
  end

  def with_error(%__MODULE__{} = value, pos_int, unit) do
    with {:ok, converted} <- convert(value.value, value.unit, unit) do
      time(converted, unit) |> with_error(pos_int, unit)
    else
      {:error, same} ->
        time(Unit.convert(same, unit), unit)
        |> with_error(pos_int, unit)
    end
  end

  defp convert(value, from_unit, to_unit) do
    # TODO : move this to unit module ??
    try do
      {:ok, Unit.convert(from_unit, to_unit).(value)}
    rescue
      _ -> {:error, value}
    end
  end
end
