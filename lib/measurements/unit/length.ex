defmodule Measurements.Unit.Length do
  @moduledoc """
    `Measurements.Unit.Length` deals with length-related units.
  """

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Scale
  alias Measurements.Unit.Parser

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

  # def dimension(other), do: raise(ArgumentError, message: argument_error_message(other))

  ###### NEW API
  def with_dimension(exp) when is_integer(exp), do: Dimension.new() |> Dimension.with_length(exp)

  @behaviour Scalable
  @impl Scalable
  # no special dimension if no unit. useful to break loop cleanly when alias not found.
  def scale(nil), do: Scale.new(0)

  # Note now we directly invoke parser. we dont care about aliases and if unit is present or not to retrieve its scale
  def scale(unit) when is_atom(unit) do
    case Parser.parse(unit) do
      {:ok, scale, _dimension} -> scale
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  def scale(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Unitable
  @impl Unitable
  @spec unit(Scale.t(), Dimension.t()) :: {:ok, atom} | {:error, fun, atom}
  def unit(
        %Scale{
          coefficient: 1,
          dimension: %Dimension{
            time: 0,
            length: l,
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
      scale == %Scale{} and convert_mag_acc == 0 and unit_atom in __units() ->
        {:ok, unit_atom}

      # if scale is not exactly 1
      convert_mag_acc == 0 and unit_atom in __units() ->
        {:error, Scale.convert(scale), unit_atom}

      # if convert_mag_acc has something we need to integrate with the current scale
      unit_atom in __units() ->
        {:error, Scale.convert(Scale.prod(scale, Scale.new(convert_mag_acc))), unit_atom}

      # recurse on magnitude towards 0 if the normalized unit is not recognised.
      # Note we reuse s and ignore previous parsing.
      s.magnitude > 0 ->
        unit(%{s | magnitude: s.magnitude - 1}, convert_mag_acc + 1)

      s.magnitude < 0 ->
        unit(%{s | magnitude: s.magnitude + 1}, convert_mag_acc - 1)

      # otherwise ignore parser result, use meter and dont forget accumulated convert scale
      l > 0 ->
        {:error, Scale.convert(Scale.prod(s, Scale.new(convert_mag_acc))), :meter}

      true ->
        {:error, Scale.convert(Scale.prod(s, Scale.new(convert_mag_acc))),
         String.to_atom("meter_#{l}")}

        # TODO : double check this always true ? should crash instead ?
    end
  end

  @spec to_string(atom) :: String.t()
  def to_string(kilometer()), do: "km"
  def to_string(meter()), do: "m"
  def to_string(millimeter()), do: "mm"
  def to_string(micrometer()), do: "μm"
  def to_string(nanometer()), do: "nm"

  def to_string(unit) when is_atom(unit) do
    {:ok, %Scale{coefficient: 1} = scale, _dim} = Parser.parse(unit)

    dim =
      cond do
        scale.dimension.length > 1 -> "s**#{scale.dimension.length}"
        scale.dimension.length == 1 -> "s"
        scale.dimension.length < 0 -> "s#{scale.dimension.length}"
      end

    scale_prefix =
      cond do
        scale.magnitude >= 18 * scale.dimension.length -> "exa"
        scale.magnitude >= 15 * scale.dimension.length -> "peta"
        scale.magnitude >= 12 * scale.dimension.length -> "tera"
        scale.magnitude >= 9 * scale.dimension.length -> "giga"
        scale.magnitude >= 6 * scale.dimension.length -> "M"
        scale.magnitude >= 3 * scale.dimension.length -> "k"
        scale.magnitude >= 0 * scale.dimension.length -> ""
        scale.magnitude >= -3 * scale.dimension.length -> "m"
        scale.magnitude >= -6 * scale.dimension.length -> "μ"
        scale.magnitude >= -9 * scale.dimension.length -> "n"
        scale.magnitude >= -12 * scale.dimension.length -> "p"
        scale.magnitude >= -15 * scale.dimension.length -> "f"
        true -> "a"
      end

    scale_prefix <> dim
  end

  defp argument_error_message(other),
    do:
      "unsupported length unit. Expected #{kilometer()}, #{meter()}, " <>
        "#{millimeter()}, #{micrometer()}, #{nanometer()}. " <>
        "Got #{inspect(other)}"
end
