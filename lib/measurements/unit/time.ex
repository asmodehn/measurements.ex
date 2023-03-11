defmodule Measurements.Unit.Time do
  @moduledoc """
    `Measurements.Unit.Time` deals with time-related units.
  """

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Scale

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

  def dimension(unit) when unit in [second(), millisecond(), microsecond(), nanosecond()],
    do: Dimension.new() |> Dimension.with_time(1)

  def dimension(ps) when is_integer(ps) and ps > 0, do: Dimension.new() |> Dimension.with_time(1)

  def dimension(unit) when unit in [hertz(), kilohertz(), megahertz(), gigahertz()],
    do: Dimension.new() |> Dimension.with_time(-1)

  def dimension(unit) when is_atom(unit), do: dimension(__alias(unit))

  def dimension(other), do: raise(ArgumentError, message: argument_error_message(other))

  ###### NEW API
  def with_dimension(exp) when is_integer(exp), do: Dimension.new() |> Dimension.with_time(exp)

  @behaviour Scalable
  @impl Scalable
  # no special scale if no unit. useful to break loop when alias not found.
  def scale(nil), do: Scale.new(0)
  def scale(unit) when is_atom(unit) and unit not in __units(), do: scale(__alias(unit))

  def scale(unit) when is_atom(unit) do
    cond do
      String.ends_with?(Atom.to_string(unit), "second") -> Scale.from_unit(unit)
      String.ends_with?(Atom.to_string(unit), "hertz") -> Scale.from_unit(unit)
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
  def unit(%Scale{coefficient: 1} = s, %Dimension{
        time: t,
        length: 0,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      })
      when t > 0 do
    with {:dimension, {:ok, unit}} <- {:dimension, {:ok, "second"}},
         # |> IO.inspect()
         {:scale, {:ok, prefixed_unit}} <- {:scale, with_scale(unit, s, t)} do
      if t == 1 do
        {:ok, prefixed_unit}
      else
        {:ok, String.to_atom(Atom.to_string(prefixed_unit) <> "_#{t}")}
      end
    else
      {:scale, {:error, convert, prefixed_unit}} ->
        if t == 1 do
          {:error, convert, prefixed_unit}
        else
          {:error, convert, String.to_atom(Atom.to_string(prefixed_unit) <> "_#{t}")}
        end
    end
  end

  def unit(%Scale{coefficient: 1} = s, %Dimension{
        time: t,
        length: 0,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      })
      when t < 0 do
    with {:dimension, {:ok, unit}} <- {:dimension, {:ok, "hertz"}},
         # CAREFUL : we need to pass -t as we are using :hertz as a unit and not :per_second"
         # |> IO.inspect()
         {:scale, {:ok, prefixed_unit}} <- {:scale, with_scale(unit, s, -t)} do
      if t == -1 do
        {:ok, prefixed_unit}
      else
        {:ok, String.to_atom(Atom.to_string(prefixed_unit) <> "_#{t}")}
      end
    else
      {:scale, {:error, convert, prefixed_unit}} ->
        if t == -1 do
          {:error, convert, prefixed_unit}
        else
          {:error, convert, String.to_atom(Atom.to_string(prefixed_unit) <> "_#{t}")}
        end
    end
  end

  @spec with_scale(String.t(), Scale.t(), integer, integer) ::
          {:ok, atom} | {:error, (term -> term), atom}
  def with_scale(unit, %Scale{magnitude: m} = s, unit_power \\ 1, convert_mag_acc \\ 0) do
    try do
      case Scale.prefix(s, unit_power) do
        {:ok, prefix} ->
          if convert_mag_acc == 0 do
            # |> IO.inspect()
            {:ok, String.to_existing_atom(prefix <> unit)}
          else
            # |> IO.inspect()
            {:error, Scale.convert(Scale.new(convert_mag_acc)),
             String.to_existing_atom(prefix <> unit)}
          end

        {:error, convert, prefix} ->
          # composing with already existing convert function
          if convert_mag_acc == 0 do
            # |> IO.inspect()
            {:error, convert, String.to_existing_atom(prefix <> unit)}
          else
            # |> IO.inspect()
            {:error, fn v -> Scale.convert(Scale.new(convert_mag_acc)).(convert.(v)) end,
             String.to_existing_atom(prefix <> unit)}
          end
      end
    rescue
      # IO.inspect(ae)
      ae in ArgumentError ->
        # converge towards 0 
        cond do
          m > 0 -> with_scale(unit, %{s | magnitude: m - 3}, unit_power, convert_mag_acc + 3)
          m < 0 -> with_scale(unit, %{s | magnitude: m + 3}, unit_power, convert_mag_acc - 3)
          true -> reraise ae, __STACKTRACE__
        end
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
