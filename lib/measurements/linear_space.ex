import TypeClass

defclass Measurements.LinearSpace do
  extend(Measurements.Additive.Group)
  # An abelian group is a group where the operation is commutative

  alias Measurements.Additive.{Monoid, Semigroup, Group}

  where do
    # redefine scale here to allow scaling by a field, not only integers like in additive group.
    def scale(g, n)
  end

  properties do
    # this makes the group abelian
    def commutativity(data) do
      a = generate(data)
      b = generate(data)
      equal?(Semigroup.sum(a, b), Semigroup.sum(b, a))
    end

    # lets define other linear space properties, even if some are already covered by the additive group definition...
    def associativity(data) do
      a = generate(data)
      b = generate(data)
      c = generate(data)

      equal?(
        Semigroup.sum(a, Semigroup.sum(b, c)),
        Semigroup.sum(Semigroup.sum(a, b), c)
      )
    end

    def identity(data) do
      a = generate(data)

      equal?(Semigroup.sum(a, Monoid.init(a)), a) and
        equal?(Semigroup.sum(Monoid.init(a), a), a)
    end

    def inverse(data) do
      a = generate(data)

      equal?(Semigroup.sum(a, Group.inverse(a)), Monoid.init(a)) and
        equal?(Semigroup.sum(Group.inverse(a), a), Monoid.init(a))
    end

    def compatible_scalar_mult(data) do
      a = generate(data)
      # TODO : replace 42.0 with a matching property test generator -> HOW ??
      equal?(
        Measurements.LinearSpace.scale(a, 4 * 3.2),
        Measurements.LinearSpace.scale(a, 4) |> Measurements.LinearSpace.scale(3.2)
      )
    end

    def identity_scalar_mult(data) do
      a = generate(data)
      # TODO : generate float somehow
      equal?(Measurements.LinearSpace.scale(a, 1), a)
    end

    def distributivity_scalar_mult_one(data) do
      a = generate(data)
      b = generate(data)

      equal?(
        Semigroup.sum(
          Measurements.LinearSpace.scale(a, 4.2),
          Measurements.LinearSpace.scale(b, 4.2)
        ),
        Measurements.LinearSpace.scale(Semigroup.sum(a, b), 4.2)
      )
    end

    def distributivity_scalar_mult_two(data) do
      a = generate(data)

      equal?(
        Measurements.LinearSpace.scale(a, 4 + 3.2),
        Semigroup.sum(
          Measurements.LinearSpace.scale(a, 4),
          Measurements.LinearSpace.scale(a, 3.2)
        )
      )
    end
  end
end

definst Measurements.LinearSpace, for: Integer do
  def scale(i, n), do: i * n
end

definst Measurements.LinearSpace, for: Float do
  def scale(f, n), do: f * n
end
