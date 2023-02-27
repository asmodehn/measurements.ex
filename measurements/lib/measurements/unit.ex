defmodule Measurements.Unit do
  require System

  alias Measurements.Unit.Time

  @type t :: atom()

  def time(unit), do: Time.new(unit)

  def convert(from_unit, to_unit) when from_unit == to_unit do
    fn v -> v end
  end

  def convert(from_unit, to_unit) do
    fn value -> value * Time.ratio(from_unit, to_unit) end
  end
end
