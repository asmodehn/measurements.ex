defmodule Measurement.Unit.RationalTest do
  use ExUnit.Case
  doctest Measurements.Unit.Rational

  alias Measurements.Unit.Rational
  import Measurements.Unit.Rational, only: [rational_one: 0]

  # Maybe simple test should be in doc instead...
  describe "rational/2" do
    test "creates a rational number from a pair of integer, simplifying the fraction" do
      assert Rational.rational(42, 10) == {21, 5}
    end

    test "accepts one integer with an implicit denominator of one" do
      assert Rational.rational(42) == {42, 1}
    end
  end

  describe "equal?/2" do
    test "check strict equality of two rationals" do
      assert Rational.equal?(Rational.rational(42, 10), Rational.rational(420, 100))
    end

    test "check equality if either is a number" do
      assert Rational.equal?(Rational.rational(1), 1)
      assert Rational.equal?(Rational.rational(1), 1.0)
      assert Rational.equal?(1, Rational.rational(1))
      assert Rational.equal?(1.0, Rational.rational(1))
    end
  end

  # describe "perturbate/2" do
  # 	test "does not change the rational, but only its internal representation by a factor" do
  # 		Rational.perturbate({42, 10}, 100) == {4200, 1000}
  # 	end
  # end

  use ExUnitProperties

  property "equal?/2 is symmetric" do
    check all(r <- Rational.generator()) do
      assert Rational.equal?(r, r)
    end
  end

  property "equal?/2 is reflexive" do
    check all(
            a <- Rational.generator(),
            b <- Rational.generator()
          ) do
      assert Rational.equal?(a, b) === Rational.equal?(b, a)
    end
  end

  property "equal?/2 is transitive" do
    # Note: For praticallity we may want to generate only one rational, and perturbate it to test equality transitivity.
    check all(
            b <- Rational.generator(),
            a <- Rational.generator(),
            c <- Rational.generator()
          ) do
      # ap <- integer(),
      # cp <- integer() do
      # 	a = Rational.perturbate(b, ap)
      # 	c = Rational.perturbate(b, ac)
      Rational.equal?(a, b) and Rational.equal?(b, c) === Rational.equal?(a, c)
    end
  end

  # => Rational is a Setoid  => HOW TO express in test/code ??

  # property "perturbate/2 is homeomorphic" do
  # 	check all r <- Rational.generator(),
  # 		p <- integer() do
  # 			assert Rational.equal?(r, Rational.perturbate(r, p))
  # 		end
  # end

  describe "from_float/1" do
    test "creates a rational number, but not always equal to the float" do
      r = Rational.from_float(4.2)
      assert Rational.equal?(4.2, r)
      # not exactly same !
      assert not Rational.equal?(r, {42, 10})
    end
  end

  describe "as_number/1" do
    test "computes a number from a rational" do
      assert Rational.as_number({42, 10}) == 4.2
    end

    test "computes an integer when possible" do
      assert Rational.as_number({72, 8}) == 9
    end
  end

  property "as_number/2 is inverse of from_float/1 for floats" do
    check all(f <- float()) do
      assert Rational.as_number(Rational.from_float(f)) == f
    end
  end

  property "as_number/2 is inverse of rational/1 for integers" do
    check all(i <- integer()) do
      assert Rational.as_number(Rational.rational(i)) == i
    end
  end

  # TODO : property instead ???

  describe "product/2" do
    test "computes the usual product of rational, as a rational" do
      assert Rational.equal?(
               Rational.product(Rational.rational(42, 100), Rational.rational(33, 20)),
               Rational.rational(42 * 33, 100 * 20)
             )
    end

    test "also accepts integer, as a rational" do
      assert Rational.equal?(
               Rational.product(Rational.rational(42, 10), 33),
               Rational.rational(1386, 10)
             )
    end
  end

  property "product/2 is associative" do
    check all(
            a <- Rational.generator(),
            b <- Rational.generator(),
            c <- Rational.generator()
          ) do
      Rational.equal?(
        Rational.product(Rational.product(a, b), c),
        Rational.product(a, Rational.product(b, c))
      )
    end
  end

  # => Rational.product/2 is a semigroup

  property "product/2 accepts one as right identity element" do
    check all(a <- Rational.generator()) do
      assert Rational.equal?(Rational.product(rational_one(), a), a)
    end
  end

  property "product/2 accepts one as left identity element" do
    check all(a <- Rational.generator()) do
      assert Rational.equal?(Rational.product(a, rational_one()), a)
    end
  end

  # => Rational.product/2 is a monoid

  property "inverse/1 produces a right inverse for product/2" do
    check all(
            r <- Rational.generator(),
            Rational.is_rational_invertible(r)
          ) do
      assert Rational.equal?(
               Rational.product(r, Rational.inverse(r)),
               rational_one()
             )
    end
  end

  property "inverse/1 produces a left inverse for product/2" do
    check all(
            r <- Rational.generator(),
            Rational.is_rational_invertible(r)
          ) do
      assert Rational.equal?(
               Rational.product(Rational.inverse(r), r),
               rational_one()
             )
    end
  end

  # => Rational.product/2 is a group with inverse/1
end
