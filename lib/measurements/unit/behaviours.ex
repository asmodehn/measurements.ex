defmodule Measurements.Unit.Dimensionable do
  @moduledoc false
  @callback dimension(atom()) :: Measurements.Dimension.t()
end

defmodule Measurements.Unit.Scalable do
  @moduledoc false
  @callback scale(atom()) :: Measurements.Scale.t()
end

defmodule Measurements.Unit.Unitable do
  @type value :: integer | float
  @moduledoc false
  @callback unit(Measurements.Scale.t(), Measurements.Dimension.t()) ::
              {:ok, Unit.t()} | {:error, (value -> value), Unit.t()}
end

# TODO : cleaner Dimensional algebra ?
