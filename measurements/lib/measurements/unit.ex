defmodule Measurements.Unit do
  require System

  alias Measurements.Unit.Time


  @typedoc "Unit Type"
  @type t :: atom()

  @doc """
  Normalizes a time unit
  """
  @spec time(atom) :: t
  def time(unit), do: Time.new(unit)

  @doc """
  Conversion algorithm from a unit to another
  """
  @spec convert(t, t) :: ((Measurements.t -> Measurements.t))
  def convert(from_unit, to_unit) when from_unit == to_unit do
    fn v -> v end
  end

  def convert(from_unit, to_unit) do
    fn value -> value * Time.ratio(from_unit, to_unit) end
  end
end
