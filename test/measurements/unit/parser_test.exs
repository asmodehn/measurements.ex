defmodule Measurements.Unit.ParserTest do
  use ExUnit.Case
  doctest Measurements.Unit.Parser

  alias Measurements.Unit.Parser

  alias Measurements.Unit.{Time, Length, Scale, Dimension}

  describe "unit/1" do
    test "recognises base units" do
      assert Parser.unit("second") == {:ok, [1, 0, {Time, 1}, 1], "", %{}, {1, 0}, 6}
      assert Parser.unit("hertz") == {:ok, [1, 0, {Time, -1}, 1], "", %{}, {1, 0}, 5}
      assert Parser.unit("meter") == {:ok, [1, 0, {Length, 1}, 1], "", %{}, {1, 0}, 5}
    end

    test "recognises scaled time units" do
      assert Parser.unit("attosecond") == {:ok, [1, -18, {Time, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("femtosecond") == {:ok, [1, -15, {Time, 1}, 1], "", %{}, {1, 0}, 11}
      assert Parser.unit("picosecond") == {:ok, [1, -12, {Time, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("nanosecond") == {:ok, [1, -9, {Time, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("microsecond") == {:ok, [1, -6, {Time, 1}, 1], "", %{}, {1, 0}, 11}
      assert Parser.unit("millisecond") == {:ok, [1, -3, {Time, 1}, 1], "", %{}, {1, 0}, 11}
      assert Parser.unit("second") == {:ok, [1, 0, {Time, 1}, 1], "", %{}, {1, 0}, 6}
      assert Parser.unit("kilosecond") == {:ok, [1, 3, {Time, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("megasecond") == {:ok, [1, 6, {Time, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("gigasecond") == {:ok, [1, 9, {Time, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("terasecond") == {:ok, [1, 12, {Time, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("petasecond") == {:ok, [1, 15, {Time, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("exasecond") == {:ok, [1, 18, {Time, 1}, 1], "", %{}, {1, 0}, 9}

      assert Parser.unit("attohertz") == {:ok, [1, -18, {Time, -1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("femtohertz") == {:ok, [1, -15, {Time, -1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("picohertz") == {:ok, [1, -12, {Time, -1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("nanohertz") == {:ok, [1, -9, {Time, -1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("microhertz") == {:ok, [1, -6, {Time, -1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("millihertz") == {:ok, [1, -3, {Time, -1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("hertz") == {:ok, [1, 0, {Time, -1}, 1], "", %{}, {1, 0}, 5}
      assert Parser.unit("kilohertz") == {:ok, [1, 3, {Time, -1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("megahertz") == {:ok, [1, 6, {Time, -1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("gigahertz") == {:ok, [1, 9, {Time, -1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("terahertz") == {:ok, [1, 12, {Time, -1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("petahertz") == {:ok, [1, 15, {Time, -1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("exahertz") == {:ok, [1, 18, {Time, -1}, 1], "", %{}, {1, 0}, 8}
    end

    test "recognises scaled length units" do
      assert Parser.unit("attometer") == {:ok, [1, -18, {Length, 1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("femtometer") == {:ok, [1, -15, {Length, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("picometer") == {:ok, [1, -12, {Length, 1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("nanometer") == {:ok, [1, -9, {Length, 1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("micrometer") == {:ok, [1, -6, {Length, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("millimeter") == {:ok, [1, -3, {Length, 1}, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("meter") == {:ok, [1, 0, {Length, 1}, 1], "", %{}, {1, 0}, 5}
      assert Parser.unit("kilometer") == {:ok, [1, 3, {Length, 1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("megameter") == {:ok, [1, 6, {Length, 1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("gigameter") == {:ok, [1, 9, {Length, 1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("terameter") == {:ok, [1, 12, {Length, 1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("petameter") == {:ok, [1, 15, {Length, 1}, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("exameter") == {:ok, [1, 18, {Length, 1}, 1], "", %{}, {1, 0}, 8}
    end

    test "recognises inverted time unit" do
      assert Parser.unit("per_second") == {:ok, [-1, 0, {Time, 1}, 1], "", %{}, {1, 0}, 10}
    end

    test "recognises time unit with exponent" do
      assert Parser.unit("second_2") == {:ok, [1, 0, {Time, 1}, 2], "", %{}, {1, 0}, 8}
      assert Parser.unit("second_3") == {:ok, [1, 0, {Time, 1}, 3], "", %{}, {1, 0}, 8}
    end

    test "recognises inverted length unit" do
      assert Parser.unit("per_meter") == {:ok, [-1, 0, {Length, 1}, 1], "", %{}, {1, 0}, 9}
    end

    test "recognises length unit with exponent" do
      assert Parser.unit("meter_2") == {:ok, [1, 0, {Length, 1}, 2], "", %{}, {1, 0}, 7}
      assert Parser.unit("meter_3") == {:ok, [1, 0, {Length, 1}, 3], "", %{}, {1, 0}, 7}
    end

    test "recognises scaled length unit with exponent" do
      assert Parser.unit("millimeter_2") == {:ok, [1, -3, {Length, 1}, 2], "", %{}, {1, 0}, 12}
    end

    test "recognises composed units" do
      assert Parser.unit("meter_second") ==
               {:ok, [1, 0, {Length, 1}, 1, 1, 0, {Time, 1}, 1], "", %{}, {1, 0}, 12}
    end

    test "recognises scaled composed units" do
      assert Parser.unit("millimeter_second") ==
               {:ok, [1, -3, {Length, 1}, 1, 1, 0, {Time, 1}, 1], "", %{}, {1, 0}, 17}

      assert Parser.unit("meter_millisecond") ==
               {:ok, [1, 0, {Length, 1}, 1, 1, -3, {Time, 1}, 1], "", %{}, {1, 0}, 17}
    end

    test "recognises scaled composed units with exponent" do
      assert Parser.unit("millimeter_second_2") ==
               {:ok, [1, -3, {Length, 1}, 1, 1, 0, {Time, 1}, 2], "", %{}, {1, 0}, 19}

      assert Parser.unit("meter_millisecond_2") ==
               {:ok, [1, 0, {Length, 1}, 1, 1, -3, {Time, 1}, 2], "", %{}, {1, 0}, 19}
    end
  end

  describe "parse" do
    test "recognises time units correctly" do
      assert Parser.parse(:second) ==
               {:ok, %{%Scale{magnitude: 0} | dimension: %Measurements.Unit.Dimension{time: 1}},
                %Measurements.Unit.Dimension{time: 1}}

      assert Parser.parse(:millisecond) ==
               {:ok, %{%Scale{magnitude: -3} | dimension: %Measurements.Unit.Dimension{time: 1}},
                %Measurements.Unit.Dimension{time: 1}}

      assert Parser.parse(:microsecond) ==
               {:ok, %{%Scale{magnitude: -6} | dimension: %Measurements.Unit.Dimension{time: 1}},
                %Measurements.Unit.Dimension{time: 1}}

      assert Parser.parse(:nanosecond) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: -9}
                  | dimension: %Measurements.Unit.Dimension{time: 1}
                }, %Measurements.Unit.Dimension{time: 1}}

      assert Parser.parse(:hertz) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 0}
                  | dimension: %Measurements.Unit.Dimension{time: -1}
                }, %Measurements.Unit.Dimension{time: -1}}

      assert Parser.parse(:kilohertz) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 3}
                  | dimension: %Measurements.Unit.Dimension{time: -1}
                }, %Measurements.Unit.Dimension{time: -1}}

      assert Parser.parse(:megahertz) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 6}
                  | dimension: %Measurements.Unit.Dimension{time: -1}
                }, %Measurements.Unit.Dimension{time: -1}}

      assert Parser.parse(:gigahertz) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 9}
                  | dimension: %Measurements.Unit.Dimension{time: -1}
                }, %Measurements.Unit.Dimension{time: -1}}
    end

    test "recognises length units correctly" do
      assert Parser.parse(:kilometer) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 3}
                  | dimension: %Measurements.Unit.Dimension{length: 1}
                }, %Measurements.Unit.Dimension{length: 1}}

      assert Parser.parse(:meter) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 0}
                  | dimension: %Measurements.Unit.Dimension{length: 1}
                }, %Measurements.Unit.Dimension{length: 1}}

      assert Parser.parse(:millimeter) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: -3}
                  | dimension: %Measurements.Unit.Dimension{length: 1}
                }, %Measurements.Unit.Dimension{length: 1}}

      assert Parser.parse(:micrometer) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: -6}
                  | dimension: %Measurements.Unit.Dimension{length: 1}
                }, %Measurements.Unit.Dimension{length: 1}}

      assert Parser.parse(:nanometer) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: -9}
                  | dimension: %Measurements.Unit.Dimension{length: 1}
                }, %Measurements.Unit.Dimension{length: 1}}
    end

    test "recognises units with scale and exponent correctly" do
      assert Parser.parse(:millisecond_2) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: -6}
                  | dimension: %Measurements.Unit.Dimension{time: 2}
                }, %Measurements.Unit.Dimension{time: 2}}

      assert Parser.parse(:kilohertz_2) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 6}
                  | dimension: %Measurements.Unit.Dimension{time: -2}
                }, %Measurements.Unit.Dimension{time: -2}}

      assert Parser.parse(:millimeter_3) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: -9}
                  | dimension: %Measurements.Unit.Dimension{length: 3}
                }, %Measurements.Unit.Dimension{length: 3}}
    end

    test "recognises composed units correctly" do
      # Absement
      assert Parser.parse(:meter_second) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 0}
                  | dimension: %Measurements.Unit.Dimension{time: 1, length: 1}
                }, %Measurements.Unit.Dimension{time: 1, length: 1}}

      # Speed
      assert Parser.parse(:meter_per_second) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 0}
                  | dimension: %Measurements.Unit.Dimension{time: -1, length: 1}
                }, %Measurements.Unit.Dimension{time: -1, length: 1}}

      # Acceleration
      assert Parser.parse(:meter_per_second_2) ==
               {:ok,
                %{
                  %Measurements.Unit.Scale{magnitude: 0}
                  | dimension: %Measurements.Unit.Dimension{time: -2, length: 1}
                }, %Measurements.Unit.Dimension{time: -2, length: 1}}
    end
  end

  describe "to_unit" do
    test "is the inverse of parse for length units" do
      {:ok, scale, dim} = Parser.parse(:kilometer)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:kilometer, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:meter)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:meter, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:millimeter)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:millimeter, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:micrometer)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:micrometer, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:nanometer)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:nanometer, Scale.new()}
    end

    test "is the inverse of parse for standard time units" do
      {:ok, scale, dim} = Parser.parse(:second)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:second, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:millisecond)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:millisecond, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:microsecond)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:microsecond, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:nanosecond)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:nanosecond, Scale.new()}

      # special case for hertz !
      {:ok, scale, dim} = Parser.parse(:hertz)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:hertz, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:kilohertz)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:kilohertz, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:megahertz)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:megahertz, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:gigahertz)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:gigahertz, Scale.new()}
    end

    test "inverts parse with scale and exponent correctly" do
      {:ok, scale, dim} = Parser.parse(:millisecond_2)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:millisecond_2, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:kilohertz_2)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:kilohertz_2, Scale.new()}

      {:ok, scale, dim} = Parser.parse(:millimeter_3)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:millimeter_3, Scale.new()}
    end

    test "inverts parse with composed units correctly" do
      # Absement
      {:ok, scale, dim} = Parser.parse(:meter_second)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:meter_second, Scale.new()}

      # Speed
      {:ok, scale, dim} = Parser.parse(:meter_per_second)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:meter_per_second, Scale.new()}

      # Acceleration
      {:ok, scale, dim} = Parser.parse(:meter_per_second_2)
      assert Parser.to_unit(%{scale | dimension: dim}) == {:meter_per_second_2, Scale.new()}
    end

    @tag :parser
    test "on error, provides correct conversion when possible" do
      {:kilometer, scale} =
        Parser.to_unit(%Scale{coefficient: 1, magnitude: 5, dimension: %Dimension{length: 1}})

      assert Scale.convert(scale).(42) == 4200

      {:kilometer, scale} =
        Parser.to_unit(%Scale{coefficient: 42, magnitude: 5, dimension: %Dimension{length: 1}})

      assert Scale.convert(scale).(1) == 4200
    end

    @tag :parser
    test "on error, with exponent, provides correct conversion" do
      {:millimeter_2, scale} =
        Parser.to_unit(%Scale{coefficient: 1, magnitude: -3, dimension: %Dimension{length: 2}})

      assert Scale.convert(scale).(42) == 42000

      {:millisecond_2, scale} =
        Parser.to_unit(%Scale{coefficient: 1, magnitude: -3, dimension: %Dimension{time: 2}})

      assert Scale.convert(scale).(42) == 42000
    end
  end
end
