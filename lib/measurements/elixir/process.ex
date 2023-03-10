defmodule Measurements.Process do
  defmodule OriginalBehaviour do
    @moduledoc """
        A small behaviour to allow mocks of some functions of interest in Elixir's `Process`.

    """

    @callback sleep(timeout()) :: :ok
  end

  @behaviour OriginalBehaviour

  @impl OriginalBehaviour
  def sleep(timeout) do
    impl().sleep(timeout)
  end

  @doc false
  defp impl, do: Application.get_env(:measurements, :process_module, Elixir.Process)
end
