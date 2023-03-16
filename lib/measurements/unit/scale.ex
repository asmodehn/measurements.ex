defmodule Measurements.Unit.Scale do
  @moduledoc """
    `Measurements.Scale` deals with the scale of a unit and related conversion
  """

  # TODO : maybe integrate that into Unit module itself ??

  alias Measurements.Unit.Dimension

  defstruct magnitude: 0,
            # default as float to cover both float and int usecase for property test
            coefficient: 1.0,
            dimension: %Dimension{}

  @typedoc "Scale Type"
  @type t :: %__MODULE__{
          # TODO : rename to :scale
          magnitude: integer,
          coefficient: integer | float,
          dimension: Dimension.t()
        }

  # coeff defaults to in for precision and simplicity.
  def new(magnitude \\ 0, coefficient \\ 1, dimension \\ %Dimension{}) do
    %__MODULE__{
      magnitude: magnitude,
      coefficient: coefficient,
      # WIP
      dimension: dimension
    }
  end

  defdelegate prod(d1, d2), to: Measurements.Multiplicative.Semigroup, as: :product

  # TODO :shortcut when d2 == 1 ?? or bad idea ?
  defdelegate ratio(d1, d2), to: Measurements.Multiplicative.Group, as: :ratio

  @doc """
  A simple way to adjust magnitude, by modifying coefficient.

  Note magnitude can only going down, to avoid reducing precision of coefficient.
  """
  def mag_down(%__MODULE__{} = s, n),
    do: %{s | coefficient: s.coefficient * 10 ** n, magnitude: s.magnitude - n}

  # TODO : exponent effect on scale.. (see to_unit in Parser module)

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

  @spec module(t) :: Atom
  def module(%__MODULE__{} = scale) do
    Dimension.module(scale.dimension)
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
      coefficient: :rand.uniform() * 1000,
      magnitude: Enum.random(-12..12)
    }
end

import TypeClass

definst Measurements.Multiplicative.Semigroup, for: Measurements.Unit.Scale do
  def product(%Measurements.Unit.Scale{} = d1, %Measurements.Unit.Scale{} = d2) do
    dim = Measurements.Unit.Dimension.sum(d1.dimension, d2.dimension)

    %Measurements.Unit.Scale{
      coefficient: d1.coefficient * d2.coefficient,
      magnitude: d1.magnitude + d2.magnitude,
      dimension: dim
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
      magnitude: -d.magnitude,
      dimension: Measurements.Unit.Dimension.opposite(d.dimension)
    }
  end

  def inverse(%Measurements.Unit.Scale{} = d) do
    %Measurements.Unit.Scale{
      coefficient: 1 / d.coefficient,
      magnitude: -d.magnitude,
      dimension: Measurements.Unit.Dimension.opposite(d.dimension)
    }
  end
end
