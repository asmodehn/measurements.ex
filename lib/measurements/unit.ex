defmodule Measurements.Unit do
  @moduledoc """
  Documentation for `Measurements.Unit`.

  A unit is represented by an atom. Ref: https://en.wikipedia.org/wiki/International_System_of_Units

  There exist multiple submodules defining the various units:
  - `Time`
  - TODO !!

  Internally, a unit relies on `Scale` and `Dimension` to determine:
  - which conversion is allowed or not.
  - which unit is better suited to a value.

  But a user does not need to know about it, it will be managed automatically, to minimize loss of precision,
  and keep the Measurement value in the integer range as much as possible.

  ## Examples

      iex> Measurements.Unit.time(:second)
      {:ok, :second}

      iex> Measurements.Unit.min(:second, :nanosecond)
      {:ok, :nanosecond}

      iex> {:ok, converter} = Measurements.Unit.convert(:second, :millisecond)
      iex> converter.(42)
      42_000

  """
  require System

  require Measurements.Unit.Time
  require Measurements.Unit.Length

  alias Measurements.Unit.Time
  alias Measurements.Unit.Length
  alias Measurements.Scale

  @typedoc "Unit Type"
  @type t :: atom()

  @type value :: integer()

  @doc """
  Normalizes a custom time unit to a known one.
  """
  @spec time(atom) :: {:ok, t} | {:error, (value -> value), t}
  @spec time(atom, integer) :: {:ok, t} | {:error, (value -> value), t}
  def time(unit, power_ten_scale \\ 0) do
    if unit in Time.__units() or Time.__alias(unit) do
      Time.unit(
        Scale.prod(Scale.new(power_ten_scale), Time.scale(unit)),
        Time.dimension(unit)
      )
    else
      {:error, :not_a_supported_time_unit}
    end
  end

  @doc """
  Normalizes a custom length unit to a known one
  """
  @spec length(atom) :: {:ok, t} | {:error, (value -> value), t}
  @spec length(atom, integer) :: {:ok, t} | {:error, (value -> value), t}
  def length(unit, power_ten_scale \\ 0) do
    if unit in Length.__units() or Length.__alias(unit) do
      # let the Length module handle it
      Length.unit(
        Scale.prod(Scale.new(power_ten_scale), Length.scale(unit)),
        Length.dimension(unit)
      )
    else
      {:error, :not_a_supported_length_unit}
    end
  end

  @doc """
  Returns the module where this unit is defined.

  Indicates which implementation to call for normalization, conversion, etc.
  """
  @spec module(atom) :: atom
  def module(unit) do
    cond do
      unit in Time.__units() -> {:ok, Time}
      unit in Length.__units() -> {:ok, Length}
      # nil if not found in aliases
      Time.__alias(unit) -> {:ok, Time}
      Length.__alias(unit) -> {:ok, Length}
      true -> {:error, :unit_module_not_found}
    end
  end

  @doc """
  Normalizes a known unit, of any dimension
  """
  @spec new(atom) :: {:ok, t} | {:error, (value -> value), t}
  def new(unit) do
    case module(unit) do
      {:ok, unit_module} ->
        unit_module.unit(
          unit_module.scale(unit),
          unit_module.dimension(unit)
        )

      {:error, what} ->
        raise what
    end
  end

  @doc """
  Conversion algorithm from a unit to another.

  Will find out which dimension the unnit belongs to, and if a conversion is possible.
  """
  @spec convert(t, t) :: {:ok, (value -> value)} | {:error, String.t()}
  def convert(from_unit, to_unit) when from_unit == to_unit do
    {:ok, &Function.identity/1}
  end

  def convert(from_unit, to_unit) do
    {:ok, unit_module} = module(from_unit)

    if unit_module.dimension(from_unit) == unit_module.dimension(to_unit) do
      {:ok, Scale.convert(Scale.ratio(unit_module.scale(from_unit), unit_module.scale(to_unit)))}
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
    {:ok, unit_module} = module(u1)

    if unit_module.dimension(u1) == unit_module.dimension(u2) do
      {:ok, if(unit_module.scale(u1) <= unit_module.scale(u2), do: u1, else: u2)}
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
    {:ok, unit_module} = module(u1)

    if unit_module.dimension(u1) == unit_module.dimension(u2) do
      {:ok, if(unit_module.scale(u1) >= unit_module.scale(u2), do: u1, else: u2)}
    else
      {:error, :incompatible_dimension}
    end
  end

  @spec to_string(atom) :: String.t()
  def to_string(unit) do
    {:ok, unit_module} = module(unit)
    unit_module.to_string(unit)
  end
end
