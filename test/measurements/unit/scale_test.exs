defmodule Measurements.Unit.ScaleTest do
  use ExUnit.Case
  doctest Measurements.Unit.Scale

  alias Measurements.Unit.Scale
  alias Measurements.Unit.Rational

  import TypeClass

  classtest(Measurements.Multiplicative.Semigroup, for: Scale)
  classtest(Measurements.Multiplicative.Monoid, for: Scale)
  classtest(Measurements.Multiplicative.Group, for: Scale)

  use ExUnitProperties

  property "Scale.product/2 is associative" do
    check all(
            s1 <- Scale.generator(),
            s2 <- Scale.generator(),
            s3 <- Scale.generator()
          ) do
      assert Measurements.Multiplicative.Semigroup.product(
               Measurements.Multiplicative.Semigroup.product(s1, s2),
               s3
             ) ==
               Measurements.Multiplicative.Semigroup.product(
                 s1,
                 Measurements.Multiplicative.Semigroup.product(s2, s3)
               )
    end
  end

  describe "from_value/2" do
    test "converts value to a scale, while keeping only integers" do
      assert Scale.from_value(42) == %Scale{
               magnitude: 0,
               coefficient: Rational.rational(42)
             }

      assert Scale.from_value(4200) == %Scale{
               magnitude: 2,
               coefficient: Rational.rational(42)
             }

      assert Scale.from_value(-4200) == %Scale{
               magnitude: 2,
               coefficient: Rational.rational(-42)
             }

      assert Scale.from_value(-4_200_000) == %Scale{
               magnitude: 5,
               coefficient: Rational.rational(-42)
             }
    end

    test "errors if zero is passed as value" do
      assert_raise ArgumentError, fn -> Scale.from_value(0) |> IO.inspect() end
    end
  end

  describe "to_value/1" do
    test "converts scale to a value" do
      assert Scale.to_value(%Scale{
               magnitude: 0,
               coefficient: Rational.rational(42)
             }) == 42

      assert Scale.to_value(%Scale{
               magnitude: 2,
               coefficient: Rational.rational(42)
             }) == 4200

      assert Scale.to_value(%Scale{
               magnitude: 2,
               coefficient: Rational.rational(-42)
             }) == -4200

      assert Scale.to_value(%Scale{
               magnitude: 5,
               coefficient: Rational.rational(-42)
             }) == -4_200_000
    end
  end

  describe "Properties:" do
    # TODO : properties testing...
    test "from_value/2 is inverse of to_value/1" do
      assert Scale.to_value(Scale.from_value(-4_200_000)) == -4_200_000
    end

    test "to_value/1 is inverse of from_value/2" do
      assert Scale.from_value(Scale.to_value(%Scale{magnitude: 5, coefficient: -42})) == %Scale{
               magnitude: 5,
               coefficient: Rational.rational(-42)
             }
    end
  end

  # TODO : test dimension
end
