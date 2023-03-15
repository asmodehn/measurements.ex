defmodule Measurements.TimestampTest do
  use ExUnit.Case
  doctest Measurements.Timestamp

  import Hammox

  alias Measurements.Timestamp

  alias Measurements.System
  alias Measurements.Node

  describe "now/1" do
    test "creates a local timestamp with monotonic time and vm offset" do
      System.OriginalMock
      |> expect(:monotonic_time, fn _unit -> 42 end)
      |> expect(:time_offset, fn _unit -> 33 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@nohost end)

      assert Timestamp.now(:millisecond) == %Timestamp{
               node: :nonode@nohost,
               unit: :millisecond,
               monotonic: 42,
               vm_offset: 33
             }
    end
  end

  describe "system_time/1" do
    test "returns a measurement for a local timestamp" do
      System.OriginalMock
      |> expect(:monotonic_time, fn _unit -> 42 end)
      |> expect(:time_offset, fn _unit -> 33 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@nohost end)

      assert Timestamp.now(:millisecond) |> Timestamp.system_time() ==
               %Measurements.Value{unit: :millisecond, value: 42 + 33}
    end
  end

  describe "delta/2" do
    test "compute the difference beween two timestamps of the same node" do
      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 42 end)
      |> expect(:monotonic_time, fn :millisecond -> 51 end)
      |> expect(:time_offset, fn :millisecond -> 33 end)
      |> expect(:time_offset, fn :millisecond -> 31 end)

      Node.OriginalMock
      |> expect(:self, 2, fn -> :nonode@nohost end)

      previous = Timestamp.now(:millisecond)
      now = Timestamp.now(:millisecond)

      assert Timestamp.delta(now, previous) ==
               %Measurements.Value{unit: :millisecond, value: 9}
    end

    test "compute the difference beween two timestamps of different node with vm_offset" do
      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 42 end)
      |> expect(:monotonic_time, fn :millisecond -> 51 end)
      |> expect(:time_offset, fn :millisecond -> 33 end)
      |> expect(:time_offset, fn :millisecond -> 31 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)
      |> expect(:self, fn -> :nonode@B end)

      previous = Timestamp.now(:millisecond)
      now = Timestamp.now(:millisecond)

      assert Timestamp.delta(now, previous) ==
               %Measurements.Value{unit: :millisecond, value: 9 - 2}
    end

    test "compute the difference beween two timestamps with conversion" do
      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 42 end)
      |> expect(:monotonic_time, fn :microsecond -> 51_000 end)
      |> expect(:time_offset, fn :millisecond -> 33 end)
      |> expect(:time_offset, fn :microsecond -> 31_000 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)
      |> expect(:self, fn -> :nonode@B end)

      previous = Timestamp.now(:millisecond)
      now = Timestamp.now(:microsecond)

      assert Timestamp.delta(now, previous) ==
               %Measurements.Value{unit: :microsecond, value: 9_000 - 2_000}
    end
  end

  describe "between/2" do
    test "computes middle timestamp between two timestamps from the same node" do
      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 42 end)
      |> expect(:time_offset, fn :millisecond -> 3 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s1 = Timestamp.now(:millisecond)

      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 51 end)
      |> expect(:time_offset, fn :millisecond -> 4 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s2 = Timestamp.now(:millisecond)

      assert Timestamp.between(s1, s2) == %Timestamp{
               node: :nonode@A,
               unit: :millisecond,
               # CAREFUL: we will lose precision here...
               monotonic: 46,
               # vm offset is the LAST one. does it matter ?
               vm_offset: 4,
               error: div(51 - 42, 2)
             }
    end

    test "computes middle timestamp between two timestamps from the same node, even in opposite order" do
      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 42 end)
      |> expect(:time_offset, fn :millisecond -> 3 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s1 = Timestamp.now(:millisecond)

      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 51 end)
      |> expect(:time_offset, fn :millisecond -> 4 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s2 = Timestamp.now(:millisecond)

      assert Timestamp.between(s2, s1) == %Timestamp{
               node: :nonode@A,
               unit: :millisecond,
               # CAREFUL: we will lose precision here...
               monotonic: 46,
               # vm offset is the LEFT one. does it matter ?
               vm_offset: 4,
               error: div(51 - 42, 2)
             }
    end
  end

  describe "sum/2" do
    test "sum two timestamps of same origin as a timestamp with error" do
      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 42 end)
      |> expect(:time_offset, fn :millisecond -> 3 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s1 = Timestamp.now(:millisecond)

      System.OriginalMock
      |> expect(:monotonic_time, fn :millisecond -> 51 end)
      |> expect(:time_offset, fn :millisecond -> 5 end)

      Node.OriginalMock
      |> expect(:self, fn -> :nonode@A end)

      s2 = Timestamp.now(:millisecond)

      assert Timestamp.sum(s2, s1) == %Timestamp{
               node: :nonode@A,
               unit: :millisecond,
               monotonic: 42 + 51,
               # offset is the average of both offsets
               vm_offset: 4,
               # error is previous error (0) + the difference in offset
               error: 2
             }
    end
  end

  describe "Measurement protocol" do
    # TODO
  end

  # TODO : test protocol String.Chars
end
