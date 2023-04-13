defmodule Measurement.Unit.RationalTest do
  use ExUnit.Case
  doctest Measurements.Unit.Rational

  alias Measurements.Unit.Rational

  # Maybe simple test should be in doc instead...
  describe "rational/2" do
    test "creates a rational number from a pair of integer, simplifying the fraction" do
      assert Rational.rational(42, 10) == %Rational{num: 21, den: 5}
    end

    test "accepts one integer with an implicit denominator of one" do
      assert Rational.rational(42) == %Rational{num: 42, den: 1}
    end
  end

  describe "equal?/2" do
    test "check strict equality of two rationals" do
      assert EqType.equal?(Rational.rational(42, 10), Rational.rational(420, 100))
    end

    test "check strit equality of internal representation of two rationals" do
      assert EqType.equal?(%Rational{num: 42, den: 10}, %Rational{num: 420, den: 100})
    end

    @tag :mememe
    test "check equality if either is a number" do
      assert EqType.equal?(1, Rational.rational(1))
      assert EqType.equal?(1.0, Rational.rational(1))
      assert EqType.equal?(Rational.rational(1), 1)
      assert EqType.equal?(Rational.rational(1), 1.0)
    end
  end

  # describe "perturbate/2" do
  # 	test "does not change the rational, but only its internal representation by a factor" do
  # 		Rational.perturbate({42, 10}, 100) == {4200, 1000}
  # 	end
  # end

  use ExUnitProperties

  import Class

  classtest(EqType, for: Rational)

  # => Rational is a Setoid  => HOW TO express in test/code ??

  # property "perturbate/2 is homeomorphic" do
  # 	check all r <- Rational.generator(),
  # 		p <- integer() do
  # 			assert Rational.equal?(r, Rational.perturbate(r, p))
  # 		end
  # end

  describe "from_float/1" do
    test "creates a rational number, similar to the float, but not always equal !" do
      r = Rational.from_float(4.2)
      # not exactly same !
      assert not EqType.equal?(r, %Rational{num: 42, den: 10})
    end
  end

  describe "as_number/1" do
    test "computes a number from a rational" do
      assert Rational.as_number(%Rational{num: 42, den: 10}) == 4.2
    end

    test "computes an integer when possible" do
      assert Rational.as_number(%Rational{num: 72, den: 8}) === 9
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
      assert EqType.equal?(
               Rational.product(Rational.rational(42, 100), Rational.rational(33, 20)),
               Rational.rational(42 * 33, 100 * 20)
             )
    end

    test "also accepts integer, as a rational" do
      assert EqType.equal?(
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
      EqType.equal?(
        Rational.product(Rational.product(a, b), c),
        Rational.product(a, Rational.product(b, c))
      )
    end
  end

  # => Rational.product/2 is a semigroup

  property "product/2 accepts default as right identity element" do
    check all(a <- Rational.generator()) do
      assert EqType.equal?(Rational.product(%Rational{}, a), a)
    end
  end

  property "product/2 accepts default as left identity element" do
    check all(a <- Rational.generator()) do
      assert EqType.equal?(Rational.product(a, %Rational{}), a)
    end
  end

  # => Rational.product/2 is a monoid

  property "inverse/1 produces a right inverse for product/2" do
    check all(
            r <- Rational.generator(),
            Rational.is_rational_invertible(r)
          ) do
      assert EqType.equal?(
               Rational.product(r, Rational.inverse(r)),
               %Rational{}
             )
    end
  end

  property "inverse/1 produces a left inverse for product/2" do
    check all(
            r <- Rational.generator(),
            Rational.is_rational_invertible(r)
          ) do
      assert EqType.equal?(
               Rational.product(Rational.inverse(r), r),
               %Rational{}
             )
    end
  end

  # => Rational.product/2 is a group with inverse/1
end
