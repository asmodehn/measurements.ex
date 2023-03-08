import TypeClass

defclass Measurements.LinearSpace do
  extend(Measurements.Additive.Group)
  # An abelian group is a group where the operation is commutative

  alias Witchcraft.Monoid
  alias Witchcraft.Semigroup
  alias Measurements.Additive

  where do
    # redefine scale here to allow scaling by a field, not only integers like in additive group.
    def scale(g, n)
  end

  properties do
    # this makes the group abelian
    def commutativity(data) do
      a = generate(data)
      b = generate(data)
      equal?(Semigroup.append(a, b), Semigroup.append(b, a))
    end

    # lets define other linear space properties, even if some are already covered by the additive group definition...
    def associativity(data) do
      a = generate(data)
      b = generate(data)
      c = generate(data)

      equal?(
        Semigroup.append(a, Semigroup.append(b, c)),
        Semigroup.append(Semigroup.append(a, b), c)
      )
    end

    def identity(data) do
      a = generate(data)

      equal?(Semigroup.append(a, Monoid.empty(a)), a) and
        equal?(Semigroup.append(Monoid.empty(a), a), a)
    end

    def inverse(data) do
      a = generate(data)

      equal?(Semigroup.append(a, Additive.Group.inverse(a)), Monoid.empty(a)) and
        equal?(Semigroup.append(Additive.Group.inverse(a), a), Monoid.empty(a))
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
        Semigroup.append(
          Measurements.LinearSpace.scale(a, 4.2),
          Measurements.LinearSpace.scale(b, 4.2)
        ),
        Measurements.LinearSpace.scale(Semigroup.append(a, b), 4.2)
      )
    end

    def distributivity_scalar_mult_two(data) do
      a = generate(data)

      equal?(
        Measurements.LinearSpace.scale(a, 4 + 3.2),
        Semigroup.append(
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
