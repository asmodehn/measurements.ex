defmodule Measurements.Unit.Length do
  @moduledoc """
    `Measurements.Unit.Length` deals with length-related units.
  """

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Scale

  alias Measurements.Unit.Dimensionable
  alias Measurements.Unit.Scalable
  alias Measurements.Unit.Unitable

  # The one place to manage the length unit atoms, for compatibility with Elixir.System
  # exposing them outside this module

  defmacro kilometer, do: quote(do: :kilometer)
  defmacro meter, do: quote(do: :meter)
  defmacro millimeter, do: quote(do: :millimeter)
  defmacro micrometer, do: quote(do: :micrometer)
  defmacro nanometer, do: quote(do: :nanometer)

  @doc """
  macro used for reflection at compile time : which units are usable with this module.
  """
  defmacro __units, do: [kilometer(), meter(), millimeter(), micrometer(), nanometer()]

  defmacro __alias(unit),
    do:
      quote(
        do:
          Keyword.get(
            [
              kilometers: unquote(kilometer()),
              meters: unquote(meter()),
              millimeters: unquote(millimeter()),
              micrometers: unquote(micrometer()),
              nanometers: unquote(nanometer())
            ],
            unquote(unit)
          )
      )

  @type t :: atom

  @behaviour Dimensionable
  @impl Dimensionable
  # no special dimension if no unit. useful to break loop cleanly when alias not found.
  def dimension(nil), do: Dimension.new()
  def dimension(kilometer()), do: Dimension.new() |> Dimension.with_length(1)
  def dimension(meter()), do: Dimension.new() |> Dimension.with_length(1)
  def dimension(millimeter()), do: Dimension.new() |> Dimension.with_length(1)
  def dimension(micrometer()), do: Dimension.new() |> Dimension.with_length(1)
  def dimension(nanometer()), do: Dimension.new() |> Dimension.with_length(1)
  def dimension(unit) when is_atom(unit), do: dimension(__alias(unit))

  def dimension(ps) when is_integer(ps) and ps > 0,
    do: Dimension.new() |> Dimension.with_length(1)

  def dimension(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Scalable
  @impl Scalable
  # no special dimension if no unit. useful to break loop cleanly when alias not found.
  def scale(nil), do: Scale.new(0)
  def scale(kilometer()), do: Scale.new(3)
  def scale(meter()), do: Scale.new(0)
  def scale(millimeter()), do: Scale.new(-3)
  def scale(micrometer()), do: Scale.new(-6)
  def scale(nanometer()), do: Scale.new(-9)
  def scale(unit) when is_atom(unit), do: scale(__alias(unit))

  def scale(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Unitable
  @impl Unitable
  @spec unit(Scale.t(), Dimension.t()) :: {:ok, atom} | {:error, fun, atom}
  def unit(%Scale{coefficient: 1} = s, %Dimension{
        time: 0,
        length: 1,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      }) do
    with {:dimension, {:ok, unit}} <- {:dimension, {:ok, "meter"}},
         {:scale, {:ok, prefixed_unit}} <- {:scale, with_scale(unit, s)} do
      {:ok, prefixed_unit}
    else
      {:scale, {:error, convert, prefixed_unit}} ->
        {:error, convert, prefixed_unit}
    end
  end

  @spec with_scale(String.t(), Scale.t(), integer) :: {:ok, atom} | {:error, (term -> term), atom}
  def with_scale(unit, %Scale{magnitude: m} = s, convert_mag_acc \\ 0) do
    try do
      case Scale.prefix(s) do
        {:ok, prefix} ->
          if convert_mag_acc == 0 do
            {:ok, String.to_existing_atom(prefix <> unit)}
          else
            {:error, Scale.convert(Scale.new(convert_mag_acc)),
             String.to_existing_atom(prefix <> unit)}
          end

        {:error, convert, prefix} ->
          # composing with already existing convert function
          if convert_mag_acc == 0 do
            {:error, convert, String.to_existing_atom(prefix <> unit)}
          else
            {:error, fn v -> Scale.convert(Scale.new(convert_mag_acc)).(convert.(v)) end,
             String.to_existing_atom(prefix <> unit)}
          end
      end
    rescue
      ae in ArgumentError ->
        # converge towards 0 
        cond do
          m > 0 -> with_scale(unit, %{s | magnitude: m - 3}, convert_mag_acc + 3)
          m < 0 -> with_scale(unit, %{s | magnitude: m + 3}, convert_mag_acc - 3)
          true -> reraise ae, __STACKTRACE__
        end
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
