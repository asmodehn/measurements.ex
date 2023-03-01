defmodule Measurements.Unit.Length do
  @moduledoc """
    `Measurements.Unit.Length` deals with length-related units.
  """

  alias Measurements.Dimension
  alias Measurements.Scale

  alias Measurements.Unit.Dimensionable
  alias Measurements.Unit.Scalable

  # The one place to manage the length unit atoms, for compatibility with Elixir.System
  # exposing them outside this module

  defmacro kilometer, do: quote(do: :kilometer)
  defmacro meter, do: quote(do: :meter)
  defmacro millimeter, do: quote(do: :millimeter)
  defmacro micrometer, do: quote(do: :micrometer)
  defmacro nanometer, do: quote(do: :nanometer)

  @doc """
  macro used for reflection at compile time : which units are defined in this module.
  """
  defmacro __units, do: [kilometer(), meter(), millimeter(), micrometer(), nanometer()]

  @type t :: atom

  @behaviour Dimensionable
  @impl Dimensionable
  def dimension(kilometer()), do: Dimension.new() |> Dimension.with_length(1)
  def dimension(meter()), do: Dimension.new() |> Dimension.with_length(1)
  def dimension(millimeter()), do: Dimension.new() |> Dimension.with_length(1)
  def dimension(micrometer()), do: Dimension.new() |> Dimension.with_length(1)
  def dimension(nanometer()), do: Dimension.new() |> Dimension.with_length(1)

  def dimension(ps) when is_integer(ps) and ps > 0,
    do: Dimension.new() |> Dimension.with_length(1)

  def dimension(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Scalable
  @impl Scalable
  def scale(kilometer()), do: Scale.new(3)
  def scale(meter()), do: Scale.new(0)
  def scale(millimeter()), do: Scale.new(-3)
  def scale(micrometer()), do: Scale.new(-6)
  def scale(nanometer()), do: Scale.new(-9)

  def scale(other), do: raise(ArgumentError, message: argument_error_message(other))

  @spec new(Scale.t(), Dimension.t()) :: {:ok, atom} | {:error, fun, atom}
  def new(%Scale{coefficient: 1} = s, %Dimension{
        time: 0,
        length: 1,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      }) do
    cond do
      s.magnitude == -9 ->
        {:ok, nanometer()}

      s.magnitude < -6 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude + 9}), nanometer()}

      s.magnitude == -6 ->
        {:ok, micrometer()}

      s.magnitude < -3 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude + 6}), micrometer()}

      s.magnitude == -3 ->
        {:ok, millimeter()}

      s.magnitude < 0 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude + 3}), millimeter()}

      # invert check order, as we inverse scale search

      s.magnitude > 3 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude - 3}), kilometer()}

      s.magnitude == 3 ->
        {:ok, kilometer()}

      s.magnitude > 0 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude}), meter()}

      s.magnitude == 0 ->
        {:ok, meter()}

      true ->
        {:error, Scale.convert(s), meter()}
    end
  end

  @spec to_string(atom) :: String.t()
  def to_string(unit) when is_atom(unit) do
    case unit do
      kilometer() -> "km"
      meter() -> "m"
      millimeter() -> "mm"
      micrometer() -> "μm"
      nanometer() -> "nm"
    end
  end

  defp argument_error_message(other),
    do:
      "unsupported length unit. Expected #{kilometer()}, #{meter()}, " <>
        "#{millimeter()}, #{micrometer()}, #{nanometer()}. " <>
        "Got #{inspect(other)}"
end
