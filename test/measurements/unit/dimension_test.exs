defmodule Measurements.Unit.DimensionTest do
  use ExUnit.Case
  doctest Measurements.Unit.Dimension

  alias Measurements.Unit.Dimension

  import Class

  classtest(Class.Semigroupoid, for: Dimension)
  classtest(Class.Category, for: Dimension)
  classtest(Class.Groupoid, for: Dimension)
end
