# defmodule Measurements.VectorSpace do
#   @moduledoc false

#   @type value :: term
#   @type factor :: float | integer

#   @callback sum(value, value) :: value
#   @callback scale(value, factor) :: value
#   @callback delta(value, value) :: value
# end
# => Vector space

# defmodule Measurements.Ring do
#   @moduledoc false
#   @type value :: term

#   @callback product(value, value) :: value
#   @callback ratio(value, value) :: value
# end
# => needs sum and diff + distribution, etc.

# defmodule Measurements.Differentiable do
#   @moduledoc false
#   @type value :: term
#   @type dt :: term

#   @callback derivative(value, value, dt) :: value
#   @callback integral(value, value, dt) :: value
# end
# => difference ring

# defmodule Measurements. do

# end
