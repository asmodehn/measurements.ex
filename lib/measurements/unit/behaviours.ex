defmodule Measurements.Unit.Dimensionable do
  @moduledoc false
  @callback dimension(atom()) :: Measurements.Dimension.t()
end

defmodule Measurements.Unit.Scalable do
  @moduledoc false
  @callback scale(atom()) :: Measurements.Scale.t()
end
