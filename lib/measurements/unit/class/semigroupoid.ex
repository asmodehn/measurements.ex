import Class

defclass Class.Semigroupoid do
  @moduledoc ~S"""
  TODO
  """

  extend(Class.Setoid, alias: true)

  @type t :: any()

  where do
    @doc ~S"""
    """
    def product(a, b)
  end

  @spec power(t(), times: non_neg_integer()) :: t()
  def power(to_repeat, times: times) do
    Stream.repeatedly(fn -> to_repeat end)
    |> Stream.take(times)
    |> Enum.reduce(&Class.Semigroupoid.product(&2, &1))
  end

  properties do
    use ExUnit.Case
    use ExUnitProperties

    property "product/2 is associative", %{module: module} do
      check all(
              a <- module.generator(),
              b <- module.generator(),
              c <- module.generator()
            ) do
        left =
          Class.Semigroupoid.product(a, b)
          |> Class.Semigroupoid.product(c)

        right =
          Class.Semigroupoid.product(
            a,
            Class.Semigroupoid.product(b, c)
          )

        assert Class.Setoid.equal?(left, right)
      end
    end
  end
end

# definst Measurements.Multiplicative.Semigroup, for: Integer do
#   def product(a, b), do: a * b
# end

# definst Measurements.Multiplicative.Semigroup, for: Float do
#   def product(a, b), do: a * b
# end
