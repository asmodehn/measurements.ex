defmodule Measurements.Unit.Time do
  @moduledoc """
    `Measurements.Unit.Time` deals with time-related units.
  """

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Scale
  alias Measurements.Unit.Parser

  import Measurements.Unit.Rational, only: [rational_one: 0]

  alias Measurements.Unit.Scalable
  alias Measurements.Unit.Unitable

  # The one place to manage the time unit atoms, for compatibility with other systems (like Elixir.System)
  # exposing them outside this module
  defmacro second, do: quote(do: :second)
  defmacro millisecond, do: quote(do: :millisecond)
  defmacro microsecond, do: quote(do: :microsecond)
  defmacro nanosecond, do: quote(do: :nanosecond)

  # defmacro attohertz, do: quote(do: :attohertz)
  # defmacro hertz, do: quote(do: :hertz)
  # defmacro kilohertz, do: quote(do: :kilohertz)
  # defmacro megahertz, do: quote(do: :megahertz)
  # defmacro gigahertz, do: quote(do: :gigahertz)

  @doc """
  macro used for reflection at compile time: which units are usable with this module.
  """
  defmacro __units,
    do: [
      second(),
      millisecond(),
      microsecond(),
      nanosecond()
      # hertz(),
      # kilohertz(),
      # megahertz(),
      # gigahertz()
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

  # @behaviour Dimensionable
  # @impl Dimensionable

  # # no special dimension if no unit. useful to break loop cleanly when alias not found.
  # def dimension(nil), do: Dimension.new()

  # def dimension(unit) when is_atom(unit) do
  #   case Parser.parse(unit) do
  #     {:ok, _scale, dimension} -> dimension
  #     {:error, reason} -> raise ArgumentError, reason
  #   end
  # end

  # def dimension(ps) when is_integer(ps) and ps > 0, do: Dimension.new() |> Dimension.with_time(1)

  # def dimension(other), do: raise(ArgumentError, message: argument_error_message(other))

  ###### NEW API
  def with_dimension(exp) when is_integer(exp), do: Dimension.new() |> Dimension.with_time(exp)

  @behaviour Scalable
  @impl Scalable
  # no special scale if no unit. useful to break loop when alias not found.
  def scale(nil), do: Scale.new(0)

  # Note now we directly invoke parser. we dont care about aliases and if unit is present or not to retrieve its scale
  def scale(unit) when is_atom(unit) do
    case Parser.parse(unit) do
      {:ok, scale, dimension} -> %{scale | dimension: dimension}
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  def scale(ps) when is_integer(ps) and ps > 0 do
    direct = Scale.from_value(ps)
    # inversion of sign here as in "per second"
    scale = %{direct | magnitude: -direct.magnitude}

    %{scale | dimension: Dimension.new() |> Dimension.with_time(1)}
  end

  def scale(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Unitable
  @impl Unitable
  @spec unit(Scale.t()) :: {:ok, atom} | {:error, fun, atom}
  def unit(
        %Scale{
          coefficient: rational_one(),
          dimension: %Dimension{
            time: t,
            length: 0,
            mass: 0,
            current: 0,
            temperature: 0,
            substance: 0,
            lintensity: 0
          }
        } = s,
        convert_mag_acc \\ 0
      ) do
    # |> IO.inspect()
    {unit_atom, scale} = Parser.to_unit(s)

    cond do
      # TODO Notice how error is not really an error, just a sign that conversion to apply is not identity.
      # => simplify API and logic ?? 
      scale.magnitude == 0 and convert_mag_acc == 0 and unit_atom in __units() ->
        {:ok, unit_atom}

      # if scale is not exactly 1
      convert_mag_acc == 0 and unit_atom in __units() ->
        {:error, Scale.convert(scale), unit_atom}

      unit_atom in __units() ->
        {:error, Scale.convert(Scale.prod(scale, Scale.new(convert_mag_acc))), unit_atom}

      # recurse on magnitude towards 0 if the normalized unit is not recognised.
      # Note we reuse s and ignore previous parsing.
      s.magnitude > 0 ->
        unit(%{s | magnitude: s.magnitude - 1}, convert_mag_acc + 1)

      s.magnitude < 0 ->
        unit(%{s | magnitude: s.magnitude + 1}, convert_mag_acc - 1)

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
  def to_string(second()), do: "s"
  def to_string(millisecond()), do: "ms"
  def to_string(microsecond()), do: "μs"
  def to_string(nanosecond()), do: "ns"
  # def to_string(hertz()), do: "Hz"
  # def to_string(kilohertz()), do: "kHz"
  # def to_string(megahertz()), do: "MHz"
  # def to_string(gigahertz()), do: "GHz"

  def to_string(unit) when is_atom(unit) do
    {:ok, %Scale{coefficient: 1} = scale, _dim} = Parser.parse(unit)

    dim =
      cond do
        scale.dimension.time > 1 -> "s**#{scale.dimension.time}"
        scale.dimension.time == 1 -> "s"
        scale.dimension.time < 0 -> "s#{scale.dimension.time}"
      end

    scale_prefix =
      cond do
        scale.magnitude >= 18 * scale.dimension.time -> "exa"
        scale.magnitude >= 15 * scale.dimension.time -> "peta"
        scale.magnitude >= 12 * scale.dimension.time -> "tera"
        scale.magnitude >= 9 * scale.dimension.time -> "giga"
        scale.magnitude >= 6 * scale.dimension.time -> "M"
        scale.magnitude >= 3 * scale.dimension.time -> "k"
        scale.magnitude >= 0 * scale.dimension.time -> ""
        scale.magnitude >= -3 * scale.dimension.time -> "m"
        scale.magnitude >= -6 * scale.dimension.time -> "μ"
        scale.magnitude >= -9 * scale.dimension.time -> "n"
        scale.magnitude >= -12 * scale.dimension.time -> "p"
        scale.magnitude >= -15 * scale.dimension.time -> "f"
        true -> "a"
      end

    scale_prefix <> dim
  end

  def to_string(unit) when is_integer(unit), do: " @ #{unit} Hz"

  defp argument_error_message(other),
    # "#{hertz()}, #{kilohertz()}, #{megahertz()}, #{gigahertz()}, " <>
    do:
      "unsupported time unit. Expected #{second()}, #{millisecond()}, " <>
        "#{microsecond()}, #{nanosecond()}, " <>
        "or any positive integer. " <>
        "Got #{inspect(other)}"
end
