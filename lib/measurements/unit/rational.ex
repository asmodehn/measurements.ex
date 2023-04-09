defmodule Measurements.Unit.Rational do
  @moduledoc """
  Implementing exact rational computation, by conversion from Floats
  """

  @type t :: {integer(), pos_integer()}

  @one {1, 1}

  defmacro rational_one, do: quote(do: unquote(@one))

  # defmacro zero(), do: {0, 1}

  # def inf(), do: {1, 0}

  # TODO : these could be macros maybe ?? optimisation -> LATER
  @spec numerator(t()) :: integer()
  defp numerator(r) do
    elem(r, 0)
  end

  @spec denominator(t()) :: pos_integer()
  defp denominator(r) do
    elem(r, 1)
  end

  defguard is_rational(r)
           when is_tuple(r) and is_integer(elem(r, 0)) and is_integer(elem(r, 1)) and
                  elem(r, 1) > 0

  defguard is_rational_invertible(r) when is_rational(r) and elem(r, 0) != 0

  @spec normalize(t()) :: t()
  defp normalize({n, d} = r) when is_rational(r) do
    # normalize by dividing by the greatest common divisor
    gcd = Integer.gcd(n, d)
    {div(n, gcd), div(d, gcd)}
  end

  @spec rational(t()) :: t()
  def rational(r) when is_rational(r) do
    r |> normalize()
  end

  @spec rational(integer()) :: t()
  def rational(n) when is_integer(n) do
    {n, 1} |> normalize()
  end

  @spec rational(integer(), pos_integer()) :: t()
  def rational(num, den) when is_integer(num) and is_integer(den) and den > 0 do
    {num, den} |> normalize()
  end

  require ExUnitProperties

  @spec generator() :: :dont_know_which_type_yet
  def generator() do
    ExUnitProperties.gen all(
                           denominator <- StreamData.positive_integer(),
                           denominator != 0,
                           numerator <- StreamData.integer()
                         ) do
      rational(numerator, denominator)
    end
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
  def as_number(r) when is_rational(r) do
    cond do
      # integer if possible
      rem(numerator(r), denominator(r)) == 0 -> div(numerator(r), denominator(r))
      true -> numerator(r) / denominator(r)
    end
  end

  @spec equal?(t(), t()) :: boolean()
  def equal?(left, right) when is_number(left) when is_number(right) do
    # rely on float/integer equality when at least one is a number
    as_number(left) == as_number(right)
  end

  # strict rational equality check
  @spec equal?(t(), t()) :: boolean()
  def equal?({ln, ld} = left, {rn, rd} = right) when is_rational(left) and is_rational(right) do
    # rely on integer exact equality
    ln === rn and ld === rd
  end

  @spec product(integer(), integer()) :: t()
  def product(n1, n2) when is_integer(n1) when is_integer(n2) do
    product(rational(n1), rational(n2))
  end

  @spec product(t(), t()) :: t()
  def product({n1, d1} = r1, {n2, d2} = r2) when is_rational(r1) and is_rational(r2) do
    {n1 * n2, d1 * d2} |> normalize()
  end

  @spec inverse(number()) :: t()
  def inverse(n) when is_integer(n) do
    inverse(rational(n))
  end

  @spec inverse(t()) :: t()
  def inverse({n, d} = r) when is_rational(r) and n > 0 do
    {d, n} |> normalize()
  end

  def inverse({n, d} = r) when is_rational(r) and n < 0 do
    # swap the sign
    {-d, -n} |> normalize()
  end

  # define ratio from inverse
  @spec ratio(integer(), integer()) :: t()
  def ratio(i1, i2) when is_integer(i1) and is_integer(i2) do
    ratio(rational(i1), rational(i2))
  end

  @spec ratio(t(), t()) :: t()
  def ratio(r1, r2) when is_rational(r1) and is_rational(r2) do
    product(r1, inverse(r2))
  end

  # explicit from_float/1 using ratio as it is usually not exact...
  # => special case, should not come into effect regarding Rational structure...
  @spec from_float(float()) :: t()
  def from_float(num) when is_float(num) do
    Float.ratio(num)
  end
end
