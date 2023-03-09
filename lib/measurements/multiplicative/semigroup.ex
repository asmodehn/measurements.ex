import TypeClass

defclass Measurements.Multiplicative.Semigroup do
  @moduledoc ~S"""
  TODO
  """

  @type t :: any()

  where do
    @doc ~S"""
    """
    def product(a, b)
  end

  @spec power(Measurements.Multiplicative.Semigroup.t(), times: non_neg_integer()) ::
          Measurements.Multiplicative.Semigroup.t()
  def power(to_repeat, times: times) do
    Stream.repeatedly(fn -> to_repeat end)
    |> Stream.take(times)
    |> Enum.reduce(&Measurements.Multiplicative.Semigroup.product(&2, &1))
  end

  properties do
    def associative(data) do
      a = generate(data)
      b = generate(data)
      c = generate(data)

      left =
        Measurements.Multiplicative.Semigroup.product(a, b)
        |> Measurements.Multiplicative.Semigroup.product(c)

      right =
        Measurements.Multiplicative.Semigroup.product(
          a,
          Measurements.Multiplicative.Semigroup.product(b, c)
        )

      cond do
        is_integer(left) or is_float(left) ->
          equal?(left, right)

        is_map(left) ->
          # comparing structures via their map, keys and values one by one.
          Enum.zip(Map.to_list(left), Map.to_list(right))
          # equal? is needed to avoid problem with float equality...
          |> Enum.map(fn {{k1, v1}, {k2, v2}} -> k1 == k2 and equal?(v1, v2) end)
          |> Enum.reduce(true, &(&1 and &2))

        true ->
          raise RuntimeError, message: "NOT IMPLEMENTED for #{left}"
      end

      # same_coefficient = equal?(left.coefficient, right.coefficient)
      # same_magnitude = equal?(left.magnitude, right.magnitude)
    end
  end
end

definst Measurements.Multiplicative.Semigroup, for: Integer do
  def product(a, b), do: a * b
end

definst Measurements.Multiplicative.Semigroup, for: Float do
  def product(a, b), do: a * b
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
