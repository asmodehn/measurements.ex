import Class

defclass Class.Setoid do
  # TODO : defclass as per https://en.wikipedia.org/wiki/Class_(set_theory)
  # => very similar to typeclass (same ? )
  # => Equivalence classes, in the sense of Scott ?
  # (cf. Scott domain semantics of lambda calculus sharing similarities with powersets)

  # generic type to be refined in module importing class
  @type t() :: any()
  # TODO : type that can be refined by implementation ??? 

  # TODO : typed_struct would be useful here...

  # callback to implement in the module defining the struct (internal data)
  @callback generator() :: t()

  @callback equal?(t(), t()) :: boolean()

  # functions for the protocol
  where do
    @doc "Check if two values are equal"
    @spec equal?(t(), t()) :: boolean()
    # which of derive or fallback is better ??
    @fallback_to_any true
    def equal?(a, b)
  end

  properties do
    use ExUnit.Case
    use ExUnitProperties

    property "equal?/2 is symmetric", %{module: module} do
      check all(r <- module.generator()) do
        assert Class.Setoid.equal?(r, r)
      end
    end

    property "equal?/2 is reflexive", %{module: module} do
      check all(
              a <- module.generator(),
              b <- module.generator()
            ) do
        assert Class.Setoid.equal?(a, b) === Class.Setoid.equal?(b, a)
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
        #   a = Rational.perturbate(b, ap)
        #   c = Rational.perturbate(b, ac)
        assert not (Class.Setoid.equal?(a, b) and Class.Setoid.equal?(b, c) and
                      not Class.Setoid.equal?(a, c))
      end
    end
  end

  # TODO: defrel to define a relationship(optimized binary function call...)
end

definst Class.Setoid, for: Any do
  def equal?(a, b) do
    # default relying on elixir's core equality
    # TODO: is sometimes the type's equal?/2 better ??
    a == b
  end
end

# TODO : macro to read the struct and produce the module with equal implemeented 

# TODO : macros to help implementing equal for other types with proper guards
