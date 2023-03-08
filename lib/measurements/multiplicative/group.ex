import TypeClass

defclass Measurements.Multiplicative.Group do
  @moduledoc ~S"""
  This is a definition of a LinearSpace, or Additive Group on top of Withcraft's monoid typeclass,
  which is defined via addition on integer and float.

  It is inspired from https://hackage.haskell.org/package/group-theory-0.2.2/docs/Data-Group.html

  """

  extend(Measurements.Multiplicative.Monoid, alias: true)

  alias Measurements.Multiplicative.Semigroup

  # A group is a monoid with invertibility

  where do
    @doc ~S"""
    An "inverse" of the passed data.
    ## Example
        iex>  Measurements.Multiplicative.Group.inverse(10)
        -10
    """
    def inverse(g)
  end

  @doc ~S"""
  A "ratio" of the passed data.
  ## Example
      iex>  Measurements.Multiplicative.Group.ratio(10, 3)
      30
      iex>  Measurements.Multiplicative.Group.ratio(3, 10)
      0.3
  """
  def ratio(g1, g2) do
    Semigroup.product(g1, inverse(g2))
  end

  @doc ~S"""
   Repeat the group operation on the passed data n-many times.
  ## Example
      iex>  Measurements.Multiplicative.Group.power(10, 2)
      20
      iex>  Measurements.Multiplicative.Group.power(10, -2)
      -20
  """
  def power(g, 0), do: Monoid.init(g)

  def power(g, n) when is_integer(n) and n > 0 do
    Semigroup.product(g, power(g, n - 1))
  end

  def power(g, n) when is_integer(n) and n < 0 do
    Semigroup.product(inverse(g), power(g, n + 1))
  end

  properties do
    def right_inverse(data) do
      a = generate(data)
      equal?(Semigroup.product(a, Measurements.Multiplicative.Group.inverse(a)), Monoid.init(a))
    end

    def left_inverse(data) do
      a = generate(data)
      equal?(Semigroup.product(Measurements.Multiplicative.Group.inverse(a), a), Monoid.init(a))
    end

    # TODO : abelian => commutativity ?
  end
end

# TODO: rational int ? or not really needed ???
# definst Measurements.Multiplicative.Group, for: Integer do
#   def inverse(i), do: 1 / i
# end

definst Measurements.Multiplicative.Group, for: Float do
  def inverse(f), do: 1 / f
end

# definst Measurements.Group.Additive, for: BitString do
#   def inverse(b), do: Bitwise.bnot(b)
# end

# definst Measurements.Group.Additive, for: List do
#   def inverse(l), do: l  # Stream in order to "consume" the list ??
# end

# definst Measurements.Group.Additive, for: Map do
#   def inverse(m), do: Witchcraft.Functor.map(m, fn e -> inverse(e) end)
# end

# definst WMeasurements.Group.Additive, for: Tuple do
#   def inverse(t), do: Witchcraft.Functor.map(sample, &Witchcraft.Monoid.empty/1)
# end

# definst Measurements.Group.Additive, for: MapSet do
#   def inverse(ms), do: MapSet.symmetric_difference(ms, Withcraft.Monoid.empty(ms))
# end

# definst Measurements.Group.Additive, for: Witchcraft.Unit do
#   require Witchcraft.Semigroup
#   def inverse(u), do: %Witchcraft.Unit{}
# end
