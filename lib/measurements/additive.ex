import TypeClass

defclass Measurements.Additive.Group do
  @moduledoc ~S"""
  This is a definition of a LinearSpace, or Additive Group on top of Withcraft's monoid typeclass,
  which is defined via addition on integer and float.

  It is inspired from https://hackage.haskell.org/package/group-theory-0.2.2/docs/Data-Group.html

  """

  extend(Measurements.Additive.Monoid)

  alias Measurements.Additive.Monoid
  alias Measurements.Additive.Semigroup

  # A group is a monoid with invertibility

  where do
    @doc ~S"""
    An "inverse" of the passed data.
    ## Example
        iex>  Measurements.Additive.Group.inverse(10)
        -10
    """
    # TODO : rename to "opposite"
    def inverse(g)
  end

  @doc ~S"""
  A "difference" of the passed data.
  ## Example
      iex>  Measurements.Additive.Group.delta(10, 3)
      7
      iex>  Measurements.Additive.Group.delta(3, 10)
      -7
  """
  def delta(g1, g2) do
    Semigroup.sum(g1, inverse(g2))
  end

  @doc ~S"""
   Repeat the group operation on the passed data n-many times.
  ## Example
      iex>  Measurements.Additive.Group.scale(10, 2)
      20
      iex>  Measurements.Additive.Group.scale(10, -2)
      -20
  """
  def scale(g, 0), do: Monoid.init(g)

  def scale(g, n) when is_integer(n) and n > 0 do
    Semigroup.sum(g, scale(g, n - 1))
  end

  def scale(g, n) when is_integer(n) and n < 0 do
    Semigroup.sum(inverse(g), scale(g, n + 1))
  end

  properties do
    def right_inverse(data) do
      a = generate(data)
      Semigroup.sum(a, Measurements.Additive.Group.inverse(a)) == Monoid.init(a)
    end

    def left_inverse(data) do
      a = generate(data)
      Semigroup.sum(Measurements.Additive.Group.inverse(a), a) == Monoid.init(a)
    end

    # TODO : Abelian ? commutativity ?? or only in linear space.
  end
end

definst Measurements.Additive.Group, for: Integer do
  def inverse(i), do: -i
end

definst Measurements.Additive.Group, for: Float do
  def inverse(f), do: -f
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
