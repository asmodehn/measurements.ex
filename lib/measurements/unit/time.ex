defmodule Measurements.Unit.Time do
  @moduledoc """
    `Measurements.Unit.Time` deals with time-related units.
  """

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Scale
  alias Measurements.Unit.Parser

  alias Measurements.Unit.Dimensionable
  alias Measurements.Unit.Scalable
  alias Measurements.Unit.Unitable

  # The one place to manage the time unit atoms, for compatibility with other systems (like Elixir.System)
  # exposing them outside this module
  defmacro second, do: quote(do: :second)
  defmacro millisecond, do: quote(do: :millisecond)
  defmacro microsecond, do: quote(do: :microsecond)
  defmacro nanosecond, do: quote(do: :nanosecond)

  defmacro attohertz, do: quote(do: :attohertz)
  defmacro hertz, do: quote(do: :hertz)
  defmacro kilohertz, do: quote(do: :kilohertz)
  defmacro megahertz, do: quote(do: :megahertz)
  defmacro gigahertz, do: quote(do: :gigahertz)

  @doc """
  macro used for reflection at compile time: which units are usable with this module.
  """
  defmacro __units,
    do: [
      second(),
      millisecond(),
      microsecond(),
      nanosecond(),
      hertz(),
      kilohertz(),
      megahertz(),
      gigahertz()
    ]

  defmacro __alias(unit),
    do:
      quote(
        do:
          Keyword.get(
            [
              seconds: unquote(second()),
              milliseconds: unquote(millisecond()),
              microseconds: unquote(microsecond()),
              nanoseconds: unquote(nanosecond())
            ],
            unquote(unit)
          )
      )

  @type t :: atom | non_neg_integer

  @behaviour Dimensionable
  @impl Dimensionable

  # no special dimension if no unit. useful to break loop cleanly when alias not found.
  def dimension(nil), do: Dimension.new()

  def dimension(unit) when is_atom(unit) do
    case Parser.parse(unit) do
      {:ok, _scale, dimension} -> dimension
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  def dimension(ps) when is_integer(ps) and ps > 0, do: Dimension.new() |> Dimension.with_time(1)

  def dimension(other), do: raise(ArgumentError, message: argument_error_message(other))

  ###### NEW API
  def with_dimension(exp) when is_integer(exp), do: Dimension.new() |> Dimension.with_time(exp)

  @behaviour Scalable
  @impl Scalable
  # no special scale if no unit. useful to break loop when alias not found.
  def scale(nil), do: Scale.new(0)

  # Note now we directly invoke parser. we dont care about aliases and if unit is present or not to retrieve its scale
  def scale(unit) when is_atom(unit) do
    case Parser.parse(unit) do
      {:ok, scale, _dimension} -> scale
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  def scale(ps) when is_integer(ps) and ps > 0 do
    direct = Scale.from_value(ps)
    # inversion of sign here as in "per second"
    %{direct | magnitude: -direct.magnitude}
  end

  def scale(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Unitable
  @impl Unitable
  @spec unit(Scale.t(), Dimension.t()) :: {:ok, atom} | {:error, fun, atom}
  def unit(
        %Scale{coefficient: 1} = s,
        %Dimension{
          time: t,
          length: 0,
          mass: 0,
          current: 0,
          temperature: 0,
          substance: 0,
          lintensity: 0
        } = d,
        convert_mag_acc \\ 0
      ) do
    {unit_atom, scale} = Parser.to_unit(s, d) |> IO.inspect()

    cond do
      # TODO Notice how error is not really an error, just a sign that conversion to apply is not identity.
      # => simplify API and logic ?? 
      scale == %Scale{} and convert_mag_acc == 0 and unit_atom in __units() ->
        {:ok, unit_atom}

      # if scale is not exactly 1
      convert_mag_acc == 0 and unit_atom in __units() ->
        {:error, Scale.convert(scale), unit_atom}

      unit_atom in __units() ->
        {:error, Scale.convert(Scale.prod(scale, Scale.new(convert_mag_acc))), unit_atom}

      # recurse on magnitude towards 0 if the normalized unit is not recognised.
      # Note we reuse s and ignore previous parsing.
      s.magnitude > 0 ->
        unit(%{s | magnitude: s.magnitude - 1}, d, convert_mag_acc + 1)

      s.magnitude < 0 ->
        unit(%{s | magnitude: s.magnitude + 1}, d, convert_mag_acc - 1)

      # rely on default unit if the normalized unit is not recognised here.
      # And ignore parser result
      t < 0 ->
        {:error, Scale.convert(Scale.prod(s, Scale.new(convert_mag_acc))), :hertz}

      # default to second
      t > 0 ->
        {:error, Scale.convert(Scale.prod(s, Scale.new(convert_mag_acc))),
         String.to_atom("second_#{t}")}

      true ->
        {:error, Scale.convert(Scale.prod(s, Scale.new(convert_mag_acc))), :second}
    end
  end

  @spec to_string(atom) :: String.t()
  def to_string(unit) when is_atom(unit) do
    case unit do
      second() -> "s"
      millisecond() -> "ms"
      microsecond() -> "μs"
      nanosecond() -> "ns"
      hertz() -> "Hz"
      kilohertz() -> "kHz"
      megahertz() -> "MHz"
      gigahertz() -> "GHz"
    end
  end

  def to_string(unit) when is_integer(unit), do: " @ #{unit} Hz"

  defp argument_error_message(other),
    do:
      "unsupported time unit. Expected #{second()}, #{millisecond()}, " <>
        "#{microsecond()}, #{nanosecond()}, #{hertz()}, #{kilohertz()}, " <>
        "#{megahertz()}, #{gigahertz()}, or any positive integer. " <>
        "Got #{inspect(other)}"
end
