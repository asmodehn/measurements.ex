defmodule Measurements.NodeTest do
  use ExUnit.Case, async: true
  doctest Measurements.Node

  alias Measurements.Node

  import Hammox
  use Hammox.Protect, module: Node, behaviour: Node.OriginalBehaviour

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "Node.self/0" do
    test "is the atom identfying the node" do
      Node.OriginalMock
      |> expect(:self, fn -> :some_node@some_host end)

      assert Node.self() == :some_node@some_host
    end
  end
end
