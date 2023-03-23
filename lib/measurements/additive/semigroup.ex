import TypeClass

defclass Measurements.Additive.Semigroup do
  @moduledoc ~S"""
  TODO
  """

  @type t :: any()

  where do
    @doc ~S"""
    """
    def sum(a, b)
  end

  @spec scale(Measurements.Additive.Semigroup.t(), times: non_neg_integer()) ::
          Measurements.Additive.Semigroup.t()
  def scale(to_repeat, times: times) do
    Stream.repeatedly(fn -> to_repeat end)
    |> Stream.take(times)
    |> Enum.reduce(&Measurements.Additive.Semigroup.sum(&2, &1))
  end

  properties do
    def associative(data) do
      # |> IO.inspect()
      a = generate(data)
      # |> IO.inspect()
      b = generate(data)
      # |> IO.inspect()
      c = generate(data)

      left =
        Measurements.Additive.Semigroup.sum(a, b)
        |> Measurements.Additive.Semigroup.sum(c)

      right =
        Measurements.Additive.Semigroup.sum(
          a,
          Measurements.Additive.Semigroup.sum(b, c)
        )

      if not equal?(left |> IO.inspect(), right |> IO.inspect()) do
        IO.inspect("(#{a} + #{b}) + #{c} != #{a} + (#{b} + #{c})")
        IO.inspect(left)
        IO.inspect(right)
        false
      else
        true
      end

      # cond do
      #   is_integer(left) or is_float(left) ->
      #     equal?(left, right)

      #   is_map(left) ->
      #     # comparing structures via their map, keys and values one by one.
      #     Enum.zip(Map.to_list(left), Map.to_list(right))
      #     # equal? is needed to avoid problem with float equality...
      #     |> Enum.map(fn {{k1, v1}, {k2, v2}} -> k1 == k2 and equal?(v1, v2) end)
      #     |> Enum.reduce(true, &(&1 and &2))

      #   true ->
      #     raise RuntimeError, message: "Measurements.Additive.Semigroup NOT IMPLEMENTED for #{left}"
      # end
    end
  end
end

definst Measurements.Additive.Semigroup, for: Integer do
  def sum(a, b), do: a + b
end

definst Measurements.Additive.Semigroup, for: Float do
  def sum(a, b), do: a + b
end
