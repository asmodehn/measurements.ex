defmodule Measurements.Unit.Derived do
  @moduledoc """
  This module contains the list of all derived physical units defined in the system.
  Ref https://en.wikipedia.org/wiki/List_of_physical_quantities, along with the corresponding base units.
  """

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Scale

  alias Measurements.Unit.Dimensionable
  alias Measurements.Unit.Scalable
  alias Measurements.Unit.Unitable

  # The one place to manage the time unit atoms, for compatibility with other systems (like Elixir.System)
  # exposing them outside this module

  # Absement
  defmacro meter_second, do: quote(do: :meter_second)
  defmacro millimeter_second, do: quote(do: :millimeter_second)
  defmacro micrometer_second, do: quote(do: :micrometer_second)
  defmacro nanometer_second, do: quote(do: :nanometer_second)

  @doc """
  macro used for reflection at compile time: which units are usable with this module.
  """
  defmacro __units,
    do: [
      meter_second(),
      millimeter_second(),
      micrometer_second(),
      nanometer_second()
    ]

  defmacro __alias(unit),
    do:
      quote(
        do:
          Keyword.get(
            [
              second_meter: unquote(meter_second()),
              millisecond_meter: unquote(millimeter_second()),
              second_millimeter: unquote(millimeter_second()),
              microsecond_meter: unquote(micrometer_second()),
              second_micrometer: unquote(micrometer_second()),
              nanosecond_meter: unquote(nanometer_second()),
              second_nanometer: unquote(nanometer_second())
            ],
            unquote(unit)
          )
      )

  @behaviour Dimensionable
  @impl Dimensionable
  # no special dimension if no unit. useful to break loop cleanly when alias not found.
  def dimension(nil), do: Dimension.new()

  def dimension(meter_second()),
    do: Dimension.new() |> Dimension.with_length(1) |> Dimension.with_time(1)

  def dimension(millimeter_second()),
    do: Dimension.new() |> Dimension.with_length(1) |> Dimension.with_time(1)

  def dimension(micrometer_second()),
    do: Dimension.new() |> Dimension.with_length(1) |> Dimension.with_time(1)

  def dimension(nanometer_second()),
    do: Dimension.new() |> Dimension.with_length(1) |> Dimension.with_time(1)

  def dimension(unit) when is_atom(unit), do: dimension(__alias(unit))

  def dimension(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Scalable
  @impl Scalable
  # no special dimension if no unit. useful to break loop cleanly when alias not found.
  def scale(nil), do: Scale.new(0)
  def scale(meter_second()), do: Scale.new(0)
  def scale(millimeter_second()), do: Scale.new(-3)
  def scale(micrometer_second()), do: Scale.new(-6)
  def scale(nanometer_second()), do: Scale.new(-9)
  def scale(unit) when is_atom(unit), do: scale(__alias(unit))

  def scale(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Unitable
  @impl Unitable
  def unit(%Scale{coefficient: 1} = s, %Dimension{
        time: 1,
        length: 1,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      }) do
    cond do
      s.magnitude == -9 ->
        {:ok, nanometer_second()}

      s.magnitude < -6 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude + 9}), nanometer_second()}

      s.magnitude == -6 ->
        {:ok, micrometer_second()}

      s.magnitude < -3 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude + 6}), micrometer_second()}

      s.magnitude == -3 ->
        {:ok, millimeter_second()}

      s.magnitude < 0 ->
        {:error, Scale.convert(%{s | magnitude: s.magnitude + 3}), millimeter_second()}

      s.magnitude == 0 ->
        {:ok, meter_second()}

      true ->
        {:error, Scale.convert(s), meter_second()}
    end
  end

  @spec to_string(atom) :: String.t()
  def to_string(unit) when is_atom(unit) do
    case unit do
      meter_second() -> "m.s"
      millimeter_second() -> "mm.s"
      micrometer_second() -> "μm.s"
      nanometer_second() -> "nm.s"
    end
  end

  defp argument_error_message(other),
    do:
      "unsupported derived unit. Expected #{meter_second()}, #{millimeter_second()}, " <>
        "#{micrometer_second()}, #{nanometer_second()}. " <>
        "Got #{inspect(other)}"
end
