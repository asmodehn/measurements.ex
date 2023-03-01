defmodule Measurements.Unit.Time do
  alias Measurements.Dimension
  alias Measurements.Scale

  alias Measurements.Unit.Dimensionable
  alias Measurements.Unit.Scalable

  # The one place to manage the time unit atoms, for compatibility with Elixir.System
  # exposing them outside this module
  defmacro second, do: quote(do: :second)
  defmacro millisecond, do: quote(do: :millisecond)
  defmacro microsecond, do: quote(do: :microsecond)
  defmacro nanosecond, do: quote(do: :nanosecond)

  defmacro hertz, do: quote(do: :hertz)
  defmacro kilohertz, do: quote(do: :kilohertz)
  defmacro megahertz, do: quote(do: :megahertz)
  defmacro gigahertz, do: quote(do: :gigahertz)

  @type t :: atom | non_neg_integer

  @behaviour Dimensionable
  @impl Dimensionable
  def dimension(second()), do: Dimension.new() |> Dimension.with_time(1)
  def dimension(millisecond()), do: Dimension.new() |> Dimension.with_time(1)
  def dimension(microsecond()), do: Dimension.new() |> Dimension.with_time(1)
  def dimension(nanosecond()), do: Dimension.new() |> Dimension.with_time(1)
  def dimension(ps) when is_integer(ps) and ps > 0, do: Dimension.new() |> Dimension.with_time(1)

  def dimension(hertz()), do: Dimension.new() |> Dimension.with_time(-1)
  def dimension(kilohertz()), do: Dimension.new() |> Dimension.with_time(-1)
  def dimension(megahertz()), do: Dimension.new() |> Dimension.with_time(-1)
  def dimension(gigahertz()), do: Dimension.new() |> Dimension.with_time(-1)

  def dimension(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Scalable
  @impl Scalable
  def scale(second()), do: Scale.new(0)
  def scale(millisecond()), do: Scale.new(-3)
  def scale(microsecond()), do: Scale.new(-6)
  def scale(nanosecond()), do: Scale.new(-9)

  def scale(ps) when is_integer(ps) and ps > 0 do
    direct = Scale.from_value(ps)
    # inversion of sign here as in "per second"
    %{direct | magnitude: -direct.magnitude}
  end

  def scale(hertz()), do: Scale.new(0)
  def scale(kilohertz()), do: Scale.new(3)
  def scale(megahertz()), do: Scale.new(6)
  def scale(gigahertz()), do: Scale.new(9)

  def scale(other), do: raise(ArgumentError, message: argument_error_message(other))

  @spec new(Scale.t(), Dimension.t()) :: {:ok, atom} | {:error, fun, atom}
  def new(%Scale{coefficient: 1} = s, %Dimension{
        time: 1,
        length: 0,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      }) do
    cond do
      s.magnitude == -9 ->
        {:ok, nanosecond()}

      s.magnitude < -6 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude + 9}), nanosecond()}

      s.magnitude == -6 ->
        {:ok, microsecond()}

      s.magnitude < -3 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude + 6}), microsecond()}

      s.magnitude == -3 ->
        {:ok, millisecond()}

      s.magnitude < 0 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude + 3}), millisecond()}

      s.magnitude == 0 ->
        {:ok, second()}

      true ->
        {:error, Scale.convert(s), second()}
    end
  end

  def new(%Scale{coefficient: 1} = s, %Dimension{
        time: -1,
        length: 0,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      }) do
    cond do
      s.magnitude > 9 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude - 9}), gigahertz()}

      s.magnitude == 9 ->
        {:ok, gigahertz()}

      s.magnitude > 6 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude - 6}), megahertz()}

      s.magnitude == 6 ->
        {:ok, megahertz()}

      s.magnitude > 3 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude - 3}), kilohertz()}

      s.magnitude == 3 ->
        {:ok, kilohertz()}

      s.magnitude == 0 ->
        {:ok, hertz()}

      true ->
        {:error, Scale.convert(s), hertz()}
    end
  end

  defp argument_error_message(other),
    do:
      "unsupported time unit. Expected #{second()}, #{millisecond()}, " <>
        "#{microsecond()}, #{nanosecond()}, #{hertz()}, #{kilohertz()}, " <>
        "#{megahertz()}, #{gigahertz()}, or any positive integer. " <>
        "Got #{inspect(other)}"
end
