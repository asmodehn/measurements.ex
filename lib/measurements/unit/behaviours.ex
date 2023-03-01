defmodule Measurements.Unit.Dimensionable do
  @callback dimension(atom()) :: Measurements.Dimension.t()
end

defmodule Measurements.Unit.Scalable do
  @callback scale(atom()) :: Measurements.Scale.t()
end
