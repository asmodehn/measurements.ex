defmodule Measurements.ProcessTest do
  use ExUnit.Case, async: true
  doctest Measurements.Process

  alias Measurements.Process

  import Hammox

  use Hammox.Protect, module: Process, behaviour: Process.OriginalBehaviour

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "Measurements.Process.sleep/1" do
    test "is a mockable wrapper around Elixir.Process.sleep/1" do
      Process.OriginalMock
      |> expect(:sleep, 1, fn
        _timeout -> :ok
      end)

      # In this test we mock the original process, and test that whatever it returns is returned
      assert Process.sleep(42) == :ok
    end
  end
end
