defmodule Measurements.Node do
  @type t() :: node()

  defmodule OriginalBehaviour do
    @moduledoc """
        A small behaviour to allow mocks of some functions of interest in Elixir's `Process`.

    """

    @callback self() :: Measurements.Node.t()
  end

  @behaviour OriginalBehaviour

  @impl OriginalBehaviour
  def self() do
    impl().self()
  end

  @doc false
  defp impl, do: Application.get_env(:measurements, :node_module, Elixir.Node)
end
