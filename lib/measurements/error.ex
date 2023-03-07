defmodule Measurements.Error do
  @moduledoc """
  	`Error` centralise the various operations related to the uncertainty error doable on measurment
  """
  alias Measurements.Unit

  @enforce_keys [:error, :unit]
  defstruct error: 0,
            unit: nil

  @typedoc "Measurement Type"
  @type t :: %__MODULE__{
          error: non_neg_integer,
          unit: Unit.t()
        }

  @spec new(integer, Unit.t()) :: t
  def new(error, unit) do
    # normalize the unit
    case Unit.new(unit) do
      # TODO : while new/2 seems the more intuitive approach, 
      # we might need a way to pass unknown units to Unit.new/2 somehow...
      # maybe create them with time/1, length/1 ??
      {:ok, nu} ->
        %__MODULE__{error: abs(error), unit: nu}

      {:error, conversion, nu} ->
        %__MODULE__{error: conversion.(abs(error)), unit: nu}
    end
  end

  @spec convert(t, Unit.t()) :: t
  def convert(%__MODULE__{} = e, unit) when unit == e.unit, do: e

  def convert(%__MODULE__{} = e, unit) do
    case Unit.min(e.unit, unit) do
      {:ok, min_unit} ->
        convert(e, min_unit, :force)

      # no conversion possible, just ignore it
      {:error, :incompatible_dimension} ->
        e
    end
  end

  def convert(%__MODULE__{} = e, unit, :force) do
    case Unit.convert(e.unit, unit) do
      {:ok, converter} ->
        %__MODULE__{
          error: converter.(e.error),
          unit: unit
        }

      # no conversion possible, raise
      {:error, :incompatible_dimension} ->
        raise ArgumentError, message: "#{unit} dimension is not compatible with #{e.unit}"
    end
  end

  # TODO
  # def sum(%__MODULE__{} = e, increment) do
  # 	%__MODULE__{}
  # end

  # def scale(error, scale) do

  # end
end
