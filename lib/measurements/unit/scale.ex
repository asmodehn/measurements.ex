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

  @spec prefix(t) :: {:ok, String.t()} | {:error, (term -> term), String.t()}
  def prefix(%__MODULE__{magnitude: m} = s, unit_power \\ 1) do
    # s |> IO.inspect()
    cond do
      m == -18 * unit_power -> {:ok, "atto"}
      m < -15 * unit_power -> {:error, convert(%{s | magnitude: m + 18 * unit_power}), "atto"}
      m == -15 * unit_power -> {:ok, "femto"}
      m < -12 * unit_power -> {:error, convert(%{s | magnitude: m + 15 * unit_power}), "femto"}
      m == -12 * unit_power -> {:ok, "pico"}
      m < -9 * unit_power -> {:error, convert(%{s | magnitude: m + 12 * unit_power}), "pico"}
      m == -9 * unit_power -> {:ok, "nano"}
      m < -6 * unit_power -> {:error, convert(%{s | magnitude: m + 9 * unit_power}), "nano"}
      m == -6 * unit_power -> {:ok, "micro"}
      m < -3 * unit_power -> {:error, convert(%{s | magnitude: m + 6 * unit_power}), "micro"}
      m == -3 * unit_power -> {:ok, "milli"}
      m < 0 * unit_power -> {:error, convert(%{s | magnitude: m + 3 * unit_power}), "milli"}
      m == 0 * unit_power -> {:ok, ""}
      m < 3 * unit_power -> {:error, convert(s), ""}
      m == 3 * unit_power -> {:ok, "kilo"}
      m < 6 * unit_power -> {:error, convert(%{s | magnitude: m - 3 * unit_power}), "kilo"}
      m == 6 * unit_power -> {:ok, "mega"}
      m < 9 * unit_power -> {:error, convert(%{s | magnitude: m - 6 * unit_power}), "mega"}
      m == 9 * unit_power -> {:ok, "giga"}
      m < 12 * unit_power -> {:error, convert(%{s | magnitude: m - 9 * unit_power}), "giga"}
      m == 12 * unit_power -> {:ok, "tera"}
      m < 15 * unit_power -> {:error, convert(%{s | magnitude: m - 12 * unit_power}), "tera"}
      m == 15 * unit_power -> {:ok, "peta"}
      m < 18 * unit_power -> {:error, convert(%{s | magnitude: m - 15 * unit_power}), "peta"}
      m == 18 * unit_power -> {:ok, :exa}
      m > 18 * unit_power -> {:error, convert(%{s | magnitude: m - 18 * unit_power}), "exa"}
    end
  end

  def from_unit(unit) when is_atom(unit) do
    strunit = Atom.to_string(unit)

    cond do
      String.starts_with?(strunit, "atto") -> new(-18)
      String.starts_with?(strunit, "femto") -> new(-15)
      String.starts_with?(strunit, "pico") -> new(-12)
      String.starts_with?(strunit, "nano") -> new(-9)
      String.starts_with?(strunit, "micro") -> new(-6)
      String.starts_with?(strunit, "milli") -> new(-3)
      String.starts_with?(strunit, "kilo") -> new(3)
      String.starts_with?(strunit, "mega") -> new(6)
      String.starts_with?(strunit, "giga") -> new(9)
      String.starts_with?(strunit, "tera") -> new(12)
      String.starts_with?(strunit, "peta") -> new(15)
      String.starts_with?(strunit, "exa") -> new(18)
      # default if prefix not recognized
      true -> new(0)
    end
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
      magnitude: d1.magnitude + d2.magnitude,
      dimension: Measurements.Unit.Dimension.sum(d1.dimension, d2.dimension)
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
