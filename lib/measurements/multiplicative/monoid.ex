import TypeClass

defclass Measurements.Multiplicative.Monoid do
  @moduledoc ~S"""
  """

  extend(Measurements.Multiplicative.Semigroup, alias: true)

  @type t :: any()

  where do
    @doc ~S"""
    """
    def init(sample)
  end

  defalias(one(sample), as: :init)

  @doc """
  Check if a value is the initial element of that type.
  """
  @spec init?(Measurements.Multiplicative.Monoid.t()) :: boolean
  def init?(monoid), do: init(monoid) == monoid

  properties do
    def left_identity(data) do
      a = generate(data)

      if is_function(a) do
        equal?(
          Semigroup.product(Measurements.Multiplicative.Monoid.init(a), a).("foo"),
          a.("foo")
        )
      else
        equal?(Semigroup.product(Measurements.Multiplicative.Monoid.init(a), a), a)
      end
    end

    def right_identity(data) do
      a = generate(data)

      if is_function(a) do
        Semigroup.product(a, Measurements.Multiplicative.Monoid.init(a)).("foo") == a.("foo")
      else
        Semigroup.product(a, Measurements.Multiplicative.Monoid.init(a)) == a
      end
    end
  end
end

definst Measurements.Multiplicative.Monoid, for: Integer do
  def init(_i), do: 1
end

definst Measurements.Multiplicative.Monoid, for: Float do
  def init(_f), do: 1.0
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
