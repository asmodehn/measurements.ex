defmodule Measurements.Unit.ParserTest do
  use ExUnit.Case
  doctest Measurements.Unit.Parser

  alias Measurements.Unit.Parser

  describe "unit/1" do
    test "recognises base units" do
      assert Parser.unit("second") == {:ok, [0, Time, 1], "", %{}, {1, 0}, 6}
      assert Parser.unit("hertz") == {:ok, [0, Time, 1], "", %{}, {1, 0}, 5}
      assert Parser.unit("meter") == {:ok, [0, Length, 1], "", %{}, {1, 0}, 5}
    end

    test "recognises scaled time units" do
      assert Parser.unit("attosecond") == {:ok, [-18, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("femtosecond") == {:ok, [-15, Time, 1], "", %{}, {1, 0}, 11}
      assert Parser.unit("picosecond") == {:ok, [-12, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("nanosecond") == {:ok, [-9, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("microsecond") == {:ok, [-6, Time, 1], "", %{}, {1, 0}, 11}
      assert Parser.unit("millisecond") == {:ok, [-3, Time, 1], "", %{}, {1, 0}, 11}
      assert Parser.unit("second") == {:ok, [0, Time, 1], "", %{}, {1, 0}, 6}
      assert Parser.unit("kilosecond") == {:ok, [3, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("megasecond") == {:ok, [6, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("gigasecond") == {:ok, [9, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("terasecond") == {:ok, [12, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("petasecond") == {:ok, [15, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("exasecond") == {:ok, [18, Time, 1], "", %{}, {1, 0}, 9}

      assert Parser.unit("attohertz") == {:ok, [-18, Time, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("femtohertz") == {:ok, [-15, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("picohertz") == {:ok, [-12, Time, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("nanohertz") == {:ok, [-9, Time, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("microhertz") == {:ok, [-6, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("millihertz") == {:ok, [-3, Time, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("hertz") == {:ok, [0, Time, 1], "", %{}, {1, 0}, 5}
      assert Parser.unit("kilohertz") == {:ok, [3, Time, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("megahertz") == {:ok, [6, Time, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("gigahertz") == {:ok, [9, Time, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("terahertz") == {:ok, [12, Time, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("petahertz") == {:ok, [15, Time, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("exahertz") == {:ok, [18, Time, 1], "", %{}, {1, 0}, 8}
    end

    test "recognises scaled length units" do
      assert Parser.unit("attometer") == {:ok, [-18, Length, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("femtometer") == {:ok, [-15, Length, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("picometer") == {:ok, [-12, Length, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("nanometer") == {:ok, [-9, Length, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("micrometer") == {:ok, [-6, Length, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("millimeter") == {:ok, [-3, Length, 1], "", %{}, {1, 0}, 10}
      assert Parser.unit("meter") == {:ok, [0, Length, 1], "", %{}, {1, 0}, 5}
      assert Parser.unit("kilometer") == {:ok, [3, Length, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("megameter") == {:ok, [6, Length, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("gigameter") == {:ok, [9, Length, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("terameter") == {:ok, [12, Length, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("petameter") == {:ok, [15, Length, 1], "", %{}, {1, 0}, 9}
      assert Parser.unit("exameter") == {:ok, [18, Length, 1], "", %{}, {1, 0}, 8}
    end

    test "recognises length unit with exponent" do
      assert Parser.unit("meter_2") == {:ok, [0, Length, 2], "", %{}, {1, 0}, 7}
      assert Parser.unit("meter_3") == {:ok, [0, Length, 3], "", %{}, {1, 0}, 7}

      assert Parser.unit("meter_-1") == {:ok, [0, Length, -1], "", %{}, {1, 0}, 8}
      assert Parser.unit("meter_+1") == {:ok, [0, Length, 1], "", %{}, {1, 0}, 8}
    end

    test "recognises scaled length unit with exponent" do
      assert Parser.unit("millimeter_2") == {:ok, [-3, Length, 2], "", %{}, {1, 0}, 12}
    end

    test "recognises composed units" do
      assert Parser.unit("meter_second") == {:ok, [0, Length, 1, 0, Time, 1], "", %{}, {1, 0}, 12}
    end

    test "recognises scaled composed units" do
      assert Parser.unit("millimeter_second") ==
               {:ok, [-3, Length, 1, 0, Time, 1], "", %{}, {1, 0}, 17}

      assert Parser.unit("meter_millisecond") ==
               {:ok, [0, Length, 1, -3, Time, 1], "", %{}, {1, 0}, 17}
    end

    test "recognises scaled composed units with exponent" do
      assert Parser.unit("millimeter_second_2") ==
               {:ok, [-3, Length, 1, 0, Time, 2], "", %{}, {1, 0}, 19}

      assert Parser.unit("meter_millisecond_2") ==
               {:ok, [0, Length, 1, -3, Time, 2], "", %{}, {1, 0}, 19}
    end
  end
end
