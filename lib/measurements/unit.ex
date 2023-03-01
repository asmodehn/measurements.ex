defmodule Measurements.Unit do
  require System

  alias Measurements.Unit.Time
  alias Measurements.Scale

  @typedoc "Unit Type"
  @type t :: atom()

  @type value :: integer()

  @doc """
  Normalizes a known unit
  """
  @spec time(atom) :: {:ok, t} | {:error, (value -> value), t}
  @spec time(atom, integer) :: {:ok, t} | {:error, (value -> value), t}
  def time(unit, power_ten_scale \\ 0) do
    Time.new(
      Scale.prod(Scale.new(power_ten_scale), Time.scale(unit)),
      Time.dimension(unit)
    )
  end

  @doc """
  Conversion algorithm from a unit to another
  """
  @spec convert(t, t) :: {:ok, (value -> value)} | {:error, String.t()}
  def convert(from_unit, to_unit) when from_unit == to_unit do
    {:ok, &Function.identity/1}
  end

  def convert(from_unit, to_unit) do
    if Time.dimension(from_unit) == Time.dimension(to_unit) do
      {:ok, Scale.convert(Scale.ratio(Time.scale(from_unit), Time.scale(to_unit)))}
    else
      {:error, :not_yet_implemented}
    end
  end

  @doc """
  finds out, for two units of the same dimension, which unit is less (in scale) than the other.
  This means the returned unit will be the most precise
  """
  @spec min(t, t) :: t
  def min(u1, u2) do
    if Time.dimension(u1) == Time.dimension(u2) do
      {:ok, if(Time.scale(u1) <= Time.scale(u2), do: u1, else: u2)}
    else
      {:error, :incompatible_dimension}
    end
  end

  @doc """
  finds out, for two units of the same dimension, which unit is more (in scale) than the other.
  This means the returned unit will be the least precise
  """
  @spec max(t, t) :: t
  def max(u1, u2) do
    if Time.dimension(u1) == Time.dimension(u2) do
      {:ok, if(Time.scale(u1) >= Time.scale(u2), do: u1, else: u2)}
    else
      {:error, :incompatible_dimension}
    end
  end
end
