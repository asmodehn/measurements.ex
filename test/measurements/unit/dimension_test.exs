defmodule Measurements.Unit.DimensionTest do
  use ExUnit.Case
  doctest Measurements.Unit.Dimension

  alias Measurements.Unit.Dimension

  import TypeClass

  classtest(Measurements.Additive.Semigroup, for: Dimension)
  classtest(Measurements.Additive.Monoid, for: Dimension)
  classtest(Measurements.Additive.Group, for: Dimension)
end
