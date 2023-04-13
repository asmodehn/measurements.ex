import Class

defclass EqType do
  # TODO : defclass as per https://en.wikipedia.org/wiki/Class_(set_theory)
  # => very similar to typeclass (same ? )
  # => Equivalence classes, in the sense of Scott ?
  # (cf. Scott domain semantics of lambda calculus sharing similarities with powersets)

  @type t() :: any()
  # TODO : type that can be refined by implementation ??? 

  # functions for the protocol
  where do
    @doc "Check if two values are equal"
    @spec equal?(t(), any()) :: boolean()
    # which of derive or fallback is better ??
    @fallback_to_any true
    def equal?(a, b)
  end

  properties do
    use ExUnit.Case
    use ExUnitProperties

    property "equal?/2 is symmetric", %{module: module} do
      check all(r <- module.generator()) do
        assert EqType.equal?(r, r)
      end
    end

    property "equal?/2 is reflexive", %{module: module} do
      check all(
              a <- module.generator(),
              b <- module.generator()
            ) do
        assert EqType.equal?(a, b) === EqType.equal?(b, a)
      end
    end

    property "equal?/2 is transitive", %{module: module} do
      # Note: For praticallity we may want to generate only one rational, and "perturbate " it to test equality transitivity.
      check all(
              b <- module.generator(),
              a <- module.generator(),
              c <- module.generator()
            ) do
        # ap <- integer(),
        # cp <- integer() do
        # 	a = Rational.perturbate(b, ap)
        # 	c = Rational.perturbate(b, ac)
        assert not (EqType.equal?(a, b) and EqType.equal?(b, c) and not EqType.equal?(a, c))
      end
    end
  end

  # TODO: defrel to define a relationship(optimized binary function call...)
end

definst EqType, for: Any do
  def equal?(a, b) do
    # End up here ? try symmetric call !
    # -> single dispatch on b this time
    # => providing symmetry without having to reimplement it for other types
    # => we rely on symmetric property tests to find eventual problems with it.
    try do
      EqType.equal?(b, a)
    rescue
      # rescue *ANY* error (depending on user's implementation of equal?/2)
      # by relying on elixir equal comparison (or strict better ??)
      # TODO : better way via macro to implement equal?/2 ???
      _ -> a == b
    end
  end
end

# TODO : macro to read the struct and produce the module with equal implemeented 

# TODO : macros to help implementing equal for other types with proper guards
