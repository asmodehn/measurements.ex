defmodule Measurements.Unit.Scale do
  @moduledoc """
    `Measurements.Scale` deals with the scale of a unit and related conversion
  """

  # TODO : maybe integrate that into Unit module itself ??

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Rational

  use Measurements.Unit.Rational

  defstruct magnitude: 0,
            coefficient: %Rational{},
            dimension: %Dimension{}

  @typedoc "Scale Type"
  @type t :: %__MODULE__{
          # TODO : rename to :scale
          magnitude: integer(),
          coefficient: Rational.t(),
          dimension: Dimension.t()
        }

  # TODO : make it always invertible by forbidding 0.
  defguard is_scale_invertible(s) when is_rational_invertible(s.coefficient)

  # coeff defaults to in for precision and simplicity.
  # Note: here we rely on coefficient as integer to avoid float arithmetic if we can.
  def new(magnitude \\ 0, coefficient \\ 1, dimension \\ %Dimension{})

  def new(magnitude, coefficient, dimension) when is_integer(coefficient) and coefficient != 0 do
    %__MODULE__{
      magnitude: magnitude,
      coefficient: Rational.rational(coefficient),
      dimension: dimension
    }
  end

  def new(magnitude, coefficient, dimension) when is_float(coefficient) and coefficient != 0.0 do
    %__MODULE__{
      magnitude: magnitude,
      # not exact, but float precision might be good enough
      coefficient: Rational.from_float(coefficient),
      dimension: dimension
    }
  end

  require ExUnitProperties

  def generator() do
    ExUnitProperties.gen all(
                           magnitude <- StreamData.integer(),
                           coefficient <- StreamData.float(min: 0.0001),
                           # coefficient != 0.0,  # coefficient cannot be zero !
                           dimension <- Dimension.generator()
                         ) do
      new(magnitude, coefficient, dimension)
    end
  end

  def prod(%Measurements.Unit.Scale{} = d1, %Measurements.Unit.Scale{} = d2) do
    dim = Measurements.Unit.Dimension.sum(d1.dimension, d2.dimension)
    coef = Rational.product(d1.coefficient, d2.coefficient)

    %Measurements.Unit.Scale{
      coefficient: coef,
      magnitude: d1.magnitude + d2.magnitude,
      dimension: dim
    }
  end

  def ratio(%Measurements.Unit.Scale{} = d1, %Measurements.Unit.Scale{} = d2) do
    # there is no diff for dimensions (not a group ?)
    dim =
      Measurements.Unit.Dimension.sum(
        d1.dimension,
        Measurements.Unit.Dimension.opposite(d2.dimension)
      )

    coef = Rational.ratio(d1.coefficient, d2.coefficient)

    %Measurements.Unit.Scale{
      coefficient: coef,
      magnitude: d1.magnitude - d2.magnitude,
      dimension: dim
    }
  end

  @doc """
  A simple way to adjust magnitude, by modifying coefficient.

  Note magnitude can only going down, to avoid reducing precision of coefficient.
  """
  def mag_down(%__MODULE__{} = s, n),
    do: %{s | coefficient: Rational.product(s.coefficient, 10 ** n), magnitude: s.magnitude - n}

  # TODO : exponent effect on scale.. (see to_unit in Parser module)

  def convert(%__MODULE__{} = scale) do
    fn v -> v * to_value(scale) end
  end

  def from_value(value, scale \\ %__MODULE__{})

  def from_value(0, %__MODULE__{}),
    do: raise(ArgumentError, message: "the value: 0 doesnt have any scale.")

  def from_value(value, %__MODULE__{} = scale) when is_integer(value) and value != 0 do
    next_coefficient = rem(value, 10)

    if next_coefficient != 0 do
      # return immediately if remainder is not zero (**multiplied by** current coefficient)
      %{scale | coefficient: Rational.product(value, scale.coefficient)}
    else
      from_value(
        div(value, 10),
        new(
          scale.magnitude + 1,
          # Note for each power of ten we need to **add** the previous coefficient
          next_coefficient * 10 ** scale.magnitude + Rational.as_number(scale.coefficient)
        )
      )
    end
  end

  @spec to_value(t) :: integer
  def to_value(%__MODULE__{} = scale) do
    Rational.as_number(scale.coefficient) * 10 ** scale.magnitude
  end

  @spec module(t) :: Atom
  def module(%__MODULE__{} = scale) do
    Dimension.module(scale.dimension)
  end
end

defimpl String.Chars, for: Measurements.Unit.Scale do
  alias Measurements.Unit.Dimension

  def to_string(%Measurements.Unit.Scale{
        coefficient: 1,
        magnitude: 0,
        dimension: d
      }) do
    {:ok, dim_mod} = Dimension.module(d)
    dim_mod.to_string(d)
  end

  def to_string(
        %Measurements.Unit.Scale{
          coefficient: 1,
          magnitude: m
        } = scale
      ) do
    s = %{scale | magnitude: 0}
    "10**#{m} #{s}"
  end

  def to_string(
        %Measurements.Unit.Scale{
          coefficient: c
        } = scale
      ) do
    s = %{scale | coefficient: 1}
    "#{c} * #{s}"
  end
end

defimpl TypeClass.Property.Generator, for: Measurements.Unit.Scale do
  alias Measurements.Unit.Rational

  def generate(_),
    do: %Measurements.Unit.Scale{
      # int between 0 to 1000
      # coefficient: :random.uniform(1000),  
      # float betweeo 0.0 and 1000.0
      coefficient: Rational.generator() |> Enum.take(1) |> List.first(),
      magnitude: Enum.random(-12..12)
    }
end

import TypeClass

definst Measurements.Multiplicative.Semigroup, for: Measurements.Unit.Scale do
  defdelegate product(d1, d2), to: Measurements.Unit.Scale, as: :prod
end

definst Measurements.Multiplicative.Monoid, for: Measurements.Unit.Scale do
  def init(_d) do
    Measurements.Unit.Scale.new()
  end
end

definst Measurements.Multiplicative.Group, for: Measurements.Unit.Scale do
  import Measurements.Unit.Rational, only: [is_rational_invertible: 1]
  import Measurements.Unit.Scale, only: [is_scale_invertible: 1]

  alias Measurements.Unit.Rational

  custom_generator(_) do
    %Measurements.Unit.Scale{
      # int between 0 to 1000
      # coefficient: :random.uniform(1000),  
      # float betweeo 0.0 and 1000.0
      coefficient:
        Rational.generator()
        |> StreamData.filter(fn r -> is_rational_invertible(r) end)
        |> Enum.take(1)
        |> List.first(),
      magnitude: Enum.random(-12..12)
    }
  end

  # inverse from ratio
  def inverse(%Measurements.Unit.Scale{} = d) when is_scale_invertible(d) do
    Measurements.Unit.Scale.ratio(Measurements.Unit.Scale.new(), d)
  end
end
