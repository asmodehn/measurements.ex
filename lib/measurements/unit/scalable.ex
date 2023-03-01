defmodule Measurements.Unit.Scalable do
  @callback scale(atom()) :: Measurements.Scale.t()
end
