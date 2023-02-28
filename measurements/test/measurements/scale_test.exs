defmodule Measurements.ScaleTest do
  use ExUnit.Case
  doctest Measurements.Scale

  alias Measurements.Scale


describe "from_value/2" do
	test "converts value to a scale, while keeping only integers" do
		
		assert Scale.from_value(42) == %Scale{
			magnitude: 0,
			coefficient: 42
		}

		assert Scale.from_value(4200) == %Scale{
			magnitude: 2,
			coefficient: 42
		}

		assert Scale.from_value(-4200) == %Scale{
			magnitude: 2,
			coefficient: -42
		}

		assert Scale.from_value(-4_200_000) == %Scale{
			magnitude: 5,
			coefficient: -42
		}

	end
end

describe "to_value/1" do
	test "converts scale to a value" do
		
		assert Scale.to_value(%Scale{
			magnitude: 0,
			coefficient: 42
		}) == 42

		assert Scale.to_value(%Scale{
			magnitude: 2,
			coefficient: 42
			}) == 4200

		assert Scale.to_value(%Scale{
			magnitude: 2,
			coefficient: -42
			}) == -4200

		assert Scale.to_value(%Scale{
			magnitude: 5,
			coefficient: -42
			}) == -4_200_000
			
	end
end

describe "Properties:" do
	#TODO : properties testing...
	test "from_value/2 is inverse of to_value/1" do
	  assert Scale.to_value(Scale.from_value(-4_200_000)) == -4_200_000
	end
	test "to_value/1 is inverse of from_value/2" do
		assert Scale.from_value(Scale.to_value(%Scale{magnitude: 5, coefficient: -42})) == %Scale{magnitude: 5, coefficient: -42}
	end
end



end