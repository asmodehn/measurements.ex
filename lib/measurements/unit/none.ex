defmodule Measurements.Unit.None do
  @moduledoc """
  This module holds definition of the unit, for unitless values.
  """

  alias Measurements.Unit.Dimension
  alias Measurements.Unit.Scale
  alias Measurements.Unit.Parser

  alias Measurements.Unit.Scalable
  alias Measurements.Unit.Unitable

  defmacro __units, do: []

  defmacro __alias(_unit), do: nil

  @type t :: nil

  # useful ? or not at all ??
  def with_dimension(0), do: Dimension.new()

  @behaviour Scalable
  @impl Scalable
  # no special scale if no unit.
  def scale(nil), do: Scale.new(0)

  def scale(other), do: raise(ArgumentError, message: argument_error_message(other))

  @behaviour Unitable
  @impl Unitable
  @spec unit(Scale.t()) :: {:ok, atom} | {:error, fun, atom}
  def unit(
        %Scale{
          coefficient: 1,
          dimension: %Dimension{
            time: 0,
            length: 0,
            mass: 0,
            current: 0,
            temperature: 0,
            substance: 0,
            lintensity: 0
          }
        } = s,
        # is it at all needed, since we dont recurse here ??
        convert_mag_acc \\ 0
      ) do
    # |> IO.inspect()
    # unit atom should always be nil here !
    {nil, scale} = Parser.to_unit(s)

    cond do
      # TODO Notice how error is not really an error, just a sign that conversion to apply is not identity.
      # => simplify API and logic ?? 
      scale == %Scale{} and convert_mag_acc == 0 ->
        {:ok, nil}

      # if scale is not exactly 1
      convert_mag_acc == 0 ->
        {:error, Scale.convert(scale), nil}

      # recurse on magnitude towards 0 as there is no magnitude in unit for unitless quantities.
      # Note we reuse s and ignore previous parsing.
      s.magnitude > 0 ->
        unit(%{s | magnitude: s.magnitude - 1}, convert_mag_acc + 1)

      s.magnitude < 0 ->
        unit(%{s | magnitude: s.magnitude + 1}, convert_mag_acc - 1)

      # otherwise ignore parser result, use nil and dont forget accumulated convert scale
      true ->
        {:error, Scale.convert(Scale.prod(s, Scale.new(convert_mag_acc))), nil}
    end
  end

  @spec to_string(atom) :: String.t()
  def to_string(nil), do: ""

  defp argument_error_message(other),
    # "#{hertz()}, #{kilohertz()}, #{megahertz()}, #{gigahertz()}, " <>
    do: "Unsupported unit identifier. Got #{inspect(other)}"
end
