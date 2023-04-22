
import Class

defmodule Measurements.Unit.Rational do
  @moduledoc """
  Implementing exact rational computation.
  This version is aimed at being an example for EqType.
  Therefore we rely on a struct and dynamic dispatch via protocols.

  Another option could be to do more in compile time, via guards and more complex macros, 
  and we could match the tuple struct of Float.ratio/1.
  But this will only -maybe- be worth it, if Rational ever aims at becoming more widely used in Elixir.
  """

  defstruct num: 1, den: 1

  @typedoc "Rational Type"
  @type t :: %__MODULE__{
          num: integer(),
          # Note: cannot be 0 ! -> typespec ??? 
          den: pos_integer()
        }

  # @one %__MODULE__{num: 1, den: 1}  # Useless since we have a struct ? unit should always be the default  TODO

  # Special elements as macros to be able to use them in guards and pattern match
  # defmacro rational_one, do: @one  # tuples are tuples in AST -> dont need a quote.

  # defmacro zero(), do: {0, 1}

  # def inf(), do: {1, 0}

  # TODO : make this disappear by preventing zero to come in the first place...
  defguard is_rational_invertible(r) when r.num != 0

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__),
        only: [
          # rational_one: 0,
          # is_rational: 1,
          is_rational_invertible: 1
        ]

      alias unquote(__MODULE__)
    end
  end

  # Maybe these are useless for a struct ?
  @spec numerator(t()) :: integer()
  def numerator(%__MODULE__{} = r) do
    r.num
  end

  @spec denominator(t()) :: pos_integer()
  def denominator(%__MODULE__{} = r) do
    r.den
  end

  @spec rational(t()) :: t()
  def rational(%__MODULE__{} = r) do
    # normalize by dividing by the greatest common divisor
    gcd = Integer.gcd(r.num, r.den)
    %__MODULE__{num: div(r.num, gcd), den: div(r.den, gcd)}
  end

  @spec rational(integer()) :: t()
  def rational(n) when is_integer(n) do
    %__MODULE__{num: n, den: 1} |> rational()
  end

  @spec rational(integer(), pos_integer()) :: t()
  def rational(num, den) when is_integer(num) and is_integer(den) and den > 0 do
    %__MODULE__{num: num, den: den} |> rational()
  end


  @behaviour Class.Setoid

  @impl Class.Setoid
  def generator() do

    require ExUnitProperties
    ExUnitProperties.gen all(
                           denominator <- StreamData.positive_integer(),
                           denominator != 0,
                           numerator <- StreamData.integer()
                         ) do
      rational(numerator, denominator)
    end
  end

  @impl Class.Setoid
  def equal?(%__MODULE__{} = left, %__MODULE__{} = right) do
    l = left |> rational()
    r = right |> rational()
    # rely on integer exact equality
    numerator(l) === numerator(r) and
      denominator(l) === denominator(r)
  end

  # Extra equality with comparable base types...
  @spec equal?(t(), integer()) :: boolean()
  def equal?(%__MODULE__{} = left, right) when is_integer(right) do
    # use the most restrictive equality by converting number to rational
    equal?(left, rational(right))  # |> IO.inspect()
  end

  @spec equal?(t(), float()) :: boolean()
  def equal?(%__MODULE__{} = left, right) when is_float(right) do
    # Note that float might give unexpected result...
    equal?(left, from_float(right))  # |> IO.inspect()
  end

  # for symmetry with integer and float
  def equal?(left, %__MODULE__{} = right) when is_float(left) when is_integer(left) do
    equal?(right, left)
  end

  # @spec perturbate(t(), integer()) :: t()
  # def perturbate(r, i) when is_rational(r) and is_integer(i) do
  # 	rational(numerator(r) * f, denominator(r) * f))
  #   end	
  # end

  @spec as_number(number()) :: number()
  def as_number(r) when is_number(r) do
    r
  end

  @spec as_number(t()) :: number()
  def as_number(%__MODULE__{} = r) do
    cond do
      # integer if possible
      rem(numerator(r), denominator(r)) == 0 -> div(numerator(r), denominator(r))
      true -> numerator(r) / denominator(r)
    end
  end

  # This should be symmetric in EqType itself !!!
  # @spec equal?(t(), t()) :: boolean()
  # def equal?(left, %__MODULE__{} = right) when is_number(left) do
  #   # rely on float/integer equality when at least one is a number
  #   as_number(left) == as_number(right)
  # end

  # # strict rational equality check
  # @spec equal?(t(), t()) :: boolean()
  # def equal?({ln, ld} = left, {rn, rd} = right) when is_rational(left) and is_rational(right) do
  #   # rely on integer exact equality
  #   ln === rn and ld === rd
  # end

  @spec product(integer(), integer()) :: t()
  def product(n1, n2) when is_integer(n1) when is_integer(n2) do
    product(rational(n1), rational(n2))
  end

  @spec product(t(), t()) :: t()
  def product(%__MODULE__{} = r1, %__MODULE__{} = r2) do
    %__MODULE__{num: r1.num * r2.num, den: r1.den * r2.den} |> rational()
  end

  @spec inverse(number()) :: t()
  def inverse(n) when is_integer(n) do
    inverse(rational(n))
  end

  @spec inverse(t()) :: t()
  def inverse(%__MODULE__{} = r) when r.num > 0 do
    %__MODULE__{num: r.den, den: r.num} |> rational()
  end

  def inverse(%__MODULE__{} = r) when r.num < 0 do
    # swap the sign
    %__MODULE__{num: -r.den, den: -r.num} |> rational()
  end

  # define ratio from inverse
  @spec ratio(integer(), integer()) :: t()
  def ratio(i1, i2) when is_integer(i1) and is_integer(i2) do
    ratio(rational(i1), rational(i2))
  end

  @spec ratio(t(), t()) :: t()
  def ratio(%__MODULE__{} = r1, %__MODULE__{} = r2) do
    product(r1, inverse(r2))
  end

  # explicit from_float/1 using ratio as it is usually not exact...
  # => special case, should not come into effect regarding Rational structure...
  @spec from_float(float()) :: t()
  def from_float(num) when is_float(num) do
    r = Float.ratio(num)
    %__MODULE__{num: elem(r, 0), den: elem(r, 1)}
  end
end

definst Class.Setoid, for: Measurements.Unit.Rational do
  defdelegate equal?(left, right), to: Measurements.Unit.Rational, as: :equal?
end
definst Class.Semigroupoid, for: Measurements.Unit.Rational do
  defdelegate product(left, right), to: Measurements.Unit.Rational, as: :product
end
definst Class.Category, for: Measurements.Unit.Rational do
  defdelegate init(a), to: Measurements.Unit.Rational, as: :rational
end
# TODO : custom generator to exclude 0 in tests here...
# definst Class.Groupoid, for: Measurements.Unit.Rational do
#   defdelegate inverse(a), to: Measurements.Unit.Rational, as: :inverse
# end


defimpl String.Chars, for: Measurements.Unit.Rational do
  use Measurements.Unit.Rational

  @spec to_string(Rational.t()) :: String.t()
  def to_string(r) do
    Rational.numerator(r) <> "/" <> Rational.denominator(r)
  end
end
