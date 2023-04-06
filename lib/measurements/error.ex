defmodule Measurements.Error do
  @moduledoc """
  	`Error` centralise the various operations related to the uncertainty error doable on measurment
  """
  alias Measurements.Unit

  defstruct error: 0,
            unit: nil

  @typedoc "Measurement Type"
  @type t :: %__MODULE__{
          error: non_neg_integer,
          unit: Unit.t()
        }

  defmodule Behaviour do
    @moduledoc false

    @type error :: non_neg_integer | float
    @type unit :: Measurements.Unit.t()

    @callback error(Measurements.Value.t()) :: error
    @callback unit(Measurements.Value.t()) :: unit
  end

  @behaviour Behaviour

  @impl Behaviour
  def error(%__MODULE__{} = v), do: v.error
  @impl Behaviour
  def unit(%__MODULE__{} = v), do: v.unit

  # Unneeded ??
  # @behaviour Access

  # OR ONLY PARTIAL IMPLEMENTATINON POSIBLE ??
  # @impl Access
  def fetch(%__MODULE__{} = v, key) do
    Map.fetch(v, key)
  end

  # OR maybe gather new() / add_errr() / convert() via Access protocol ?
  # OR better custom protocol ???

  # @impl Access
  # def get_and_update(%__MODULE__{} = v, key, fun) do
  #   Map.get_and_update(v, key, fun)
  # end

  # @impl Access
  # def pop(%__MODULE__{} = v, key) do
  #   Map.get_and_update(v, key, fn v -> {v, nil} end)
  # end

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

  @doc """
  The sum of multiple measurements, with implicit unit conversion.

  Only measurements with the same unit dimension will work.
  Error will be propagated.

  ## Examples

      iex>  m1 = Measurements.Error.new(42, :second) 
      iex>  m2 = Measurements.Error.new(543, :millisecond)
      iex> Measurements.Error.sum(m1, m2)
      %Measurements.Error{
        error: 42_543,
        unit: :millisecond
      }

  """
  defdelegate sum(e1, e2), to: Measurements.Additive.Semigroup, as: :sum

  @doc """
  Scales a measurement by a number.

  No unit conversion happens at this stage for simplicity, and to keep the scale of the resulting value obvious.
  Error will be scaled by the same number, but always remains positive.

  ## Examples

        iex>  m1 = Measurements.Error.new(543, :millisecond)
        iex> Measurements.Error.scale(m1, 10)
        %Measurements.Error{
          error: 5430,
          unit: :millisecond
        }

  """
  def scale(%__MODULE__{} = e, n) when is_integer(n) do
    Measurements.Additive.Semigroup.scale(e, times: n)
    # new(abs(e.error * n), e.unit)
  end
end

defimpl String.Chars, for: Measurements.Error do
  def to_string(%Measurements.Error{
        error: e,
        unit: unit
      }) do
    u = Measurements.Unit.to_string(unit)

    "±#{e} #{u}"
  end
end

import TypeClass

defimpl TypeClass.Property.Generator, for: Measurements.Error do
  require Measurements.Unit.Time
  require Measurements.Unit.Length

  def generate(_),
    do:
      Measurements.Error.new(
        :rand.uniform(1000),
        Enum.random(Measurements.Unit.Time.__units() ++ Measurements.Unit.Length.__units())
      )
end

# defimpl TypeClass.Property.Equal, for: Measurements.Error do
#   def equal?(a, b)
#     equal?(a.error, b.error) and equal?(a.unit, b.unit)
#   end
# end

definst Measurements.Additive.Semigroup, for: Measurements.Error do
  require Measurements.Unit.Time
  require Measurements.Unit.Length

  custom_generator(_) do
    Measurements.Error.new(
      :rand.uniform(1000),
      # Enum.random(Measurements.Unit.Time.__units() ++ Measurements.Unit.Length.__units())
      # Enum.random(Measurements.Unit.Time.__units() ) # not working because Hz and second in same module...
      Enum.random(Measurements.Unit.Length.__units())
      # TODO : handle unit algebra ? how ??
    )
  end

  def sum(%Measurements.Error{} = e1, %Measurements.Error{} = e2)
      when e1.unit == e2.unit do
    # IO.inspect("#{e1} + #{e2} -> ")
    %Measurements.Error{
      error: e1.error + e2.error,
      unit: e1.unit
    }
  end

  def sum(%Measurements.Error{} = e1, %Measurements.Error{} = e2) do
    with {^e1, {:ok, s1}} <- {e1, Measurements.Unit.scale(e1.unit)},
         {^e2, {:ok, s2}} <- {e2, Measurements.Unit.scale(e2.unit)} do
      if s1.dimension == s2.dimension do
        e1 = Measurements.Error.convert(e1, e2.unit)
        e2 = Measurements.Error.convert(e2, e1.unit)
        sum(e1, e2)
      else
        raise ArgumentError, message: "#{e1} and #{e2} have incompatible unit dimension"
      end
    end
  end
end

definst Measurements.Additive.Monoid, for: Measurements.Error do
  # Monoid on the same unit !!
  def init(e), do: %Measurements.Error{unit: e.unit}
end
