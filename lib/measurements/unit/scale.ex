defmodule Measurements.Unit.Scale do
  @moduledoc """
    `Measurements.Scale` deals with the scale of a unit and related conversion
  """

  defstruct magnitude: 0,
            # default as float to cover both float and int usecase for property test
            coefficient: 1.0

  @typedoc "Scale Type"
  @type t :: %__MODULE__{
          magnitude: integer,
          coefficient: integer | float
        }

  # coeff defaults to in for precision and simplicity.
  def new(magnitude \\ 0, coefficient \\ 1) do
    %__MODULE__{
      magnitude: magnitude,
      coefficient: coefficient
    }
  end

  defdelegate prod(d1, d2), to: Measurements.Multiplicative.Semigroup, as: :product

  defdelegate ratio(d1, d2), to: Measurements.Multiplicative.Group, as: :ratio
  # def product(%__MODULE__{} = s1, %__MODULE__{} = s2) do
  #   %__MODULE__{
  #     magnitude: s1.magnitude + s2.magnitude,
  #     coefficient: s1.coefficient * s2.coefficient
  #   }
  # end

  # def ratio(%__MODULE__{} = s1, %__MODULE__{coefficient: 1} = s2) do
  #   # special case for coefficient 1 to not end up with a float if we can avoid it
  #   %__MODULE__{
  #     magnitude: s1.magnitude - s2.magnitude,
  #     coefficient: s1.coefficient
  #   }
  # end

  # def ratio(%__MODULE__{} = s1, %__MODULE__{} = s2) do
  #   %__MODULE__{
  #     magnitude: s1.magnitude - s2.magnitude,
  #     coefficient: s1.coefficient / s2.coefficient
  #   }
  # end

  def convert(%__MODULE__{} = scale) do
    fn v -> v * to_value(scale) end
  end

  def from_value(value, scale \\ %__MODULE__{})
  def from_value(0, %__MODULE__{} = scale), do: scale

  def from_value(value, %__MODULE__{} = scale) when is_integer(value) do
    next_coefficient = rem(value, 10)

    if next_coefficient != 0 do
      # return immediately if remainder is not zero (**multiplied by** current coefficient)
      %{scale | coefficient: value * scale.coefficient}
    else
      from_value(
        div(value, 10),
        new(
          scale.magnitude + 1,
          # Note for each power of ten we need to **add** the previous coefficient
          next_coefficient * 10 ** scale.magnitude + scale.coefficient
        )
      )
    end
  end

  @spec to_value(t) :: integer
  def to_value(%__MODULE__{} = scale) do
    scale.coefficient * 10 ** scale.magnitude
  end
end

defimpl String.Chars, for: Measurements.Unit.Scale do
  def to_string(%Measurements.Unit.Scale{
        coefficient: 1,
        magnitude: m
      }) do
    "10**#{m}"
  end

  def to_string(%Measurements.Unit.Scale{
        coefficient: c,
        magnitude: m
      }) do
    "#{c} * 10**#{m}"
  end
end

defimpl TypeClass.Property.Generator, for: Measurements.Unit.Scale do
  def generate(_),
    do: %Measurements.Unit.Scale{
      # coefficient: :random.uniform(1000),  # int between 0 to 1000
      # float betweeo 0.0 and 1000.0
      coefficient: :random.uniform() * 1000,
      magnitude: Enum.random(-12..12)
    }
end

import TypeClass

definst Measurements.Multiplicative.Semigroup, for: Measurements.Unit.Scale do
  def product(%Measurements.Unit.Scale{} = d1, %Measurements.Unit.Scale{} = d2) do
    %Measurements.Unit.Scale{
      coefficient: d1.coefficient * d2.coefficient,
      magnitude: d1.magnitude + d2.magnitude
    }
  end
end

definst Measurements.Multiplicative.Monoid, for: Measurements.Unit.Scale do
  def init(_d) do
    %Measurements.Unit.Scale{}
  end
end

definst Measurements.Multiplicative.Group, for: Measurements.Unit.Scale do
  def inverse(%Measurements.Unit.Scale{coefficient: 1} = d) do
    %Measurements.Unit.Scale{
      # special case: avoiding division.
      coefficient: 1,
      magnitude: -d.magnitude
    }
  end

  def inverse(%Measurements.Unit.Scale{} = d) do
    %Measurements.Unit.Scale{
      coefficient: 1 / d.coefficient,
      magnitude: -d.magnitude
    }
  end
end
