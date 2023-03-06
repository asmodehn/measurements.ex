defmodule Measurements do
  @moduledoc """
  Documentation for `Measurements`.

  A measurement is a quantity represented, by a value, a unit and an error.

  The value is usually an integer to maintain maximum precision,
  but can also be a float if required.

  ## Examples

      iex> Measurements.time(42, :second)
      %Measurements.Value{
        value: 42,
        unit: :second,
        error: 0
      }
  """

  ## only for now, for ratio...
  require Measurements.Unit.Scale

  alias Measurements.Unit
  alias Measurements.Value

  @doc """
  Time Measurement.

  ## Examples

      iex> Measurements.time(42, :second)
      %Measurements.Value{
        value: 42,
        unit: :second
      }

  """
  @spec time(integer, Unit.t()) :: Value.t()
  @spec time(integer, Unit.t(), integer) :: Value.t()
  def time(v, unit, err \\ 0) do
    # normalize the unit
    case Unit.time(unit) do
      {:ok, nu} ->
        Value.new(v, nu, abs(err))

      {:error, conversion, nu} ->
        Value.new(conversion.(v), nu, abs(err))

      {:error, :not_a_supported_time_unit} ->
        raise ArgumentError, message: "#{unit} is not a supported time unit"
    end
  end

  @doc """
  Length Measurement.

  ## Examples

      iex> Measurements.length(42, :meter)
      %Measurements.Value{
        value: 42,
        unit: :meter
      }

  """
  @spec length(integer, Unit.t()) :: Value.t()
  @spec length(integer, Unit.t(), integer) :: Value.t()
  def length(v, unit, err \\ 0) do
    # normalize the unit
    case Unit.length(unit) do
      {:ok, nu} ->
        Value.new(v, nu, abs(err))

      {:error, conversion, nu} ->
        Value.new(conversion.(v), nu, abs(err))

      {:error, :not_a_supported_length_unit} ->
        raise ArgumentError, message: "#{unit} is not a supported length unit"
    end
  end

  @doc """
  The sum of multiple measurements, with implicit unit conversion.

  Only measurements with the same unit dimension will work.
  Error will be propagated.

  ## Examples

      iex>  m1 = Measurements.time(42, :second) |> Measurements.Value.add_error(1, :second)
      iex>  m2 = Measurements.time(543, :millisecond) |> Measurements.Value.add_error(3, :millisecond)
      iex> Measurements.sum(m1, m2)
      %Measurements.Value{
        value: 42_543,
        unit: :millisecond,
        error: 1_003
      }

  """

  def sum(%module{} = m1, %module{} = m2), do: module.sum(m1, m2)

  def sum(%impl1{} = m1, %impl2{} = m2) do
    cond do
      impl1.unit(m1) == impl2.unit(m2) ->
        Value.new(
          impl1.value(m1) + impl2.value(m2),
          impl1.unit(m1),
          impl1.error(m1) + impl2.error(m2)
        )

      Unit.dimension(impl1.unit(m1)) == Unit.dimension(impl2.unit(m2)) ->
        m1 = impl1.convert(m1, impl2.unit(m2))
        m2 = impl2.convert(m2, impl1.unit(m1))
        sum(m1, m2)

      true ->
        raise ArgumentError, message: "#{m1} and #{m2} have incompatible unit dimension"
    end
  end

  @doc """
  Scales a measurement by a number.

  No unit conversion happens at this stage for simplicity, and to keep the scale of the resulting value obvious.
  Error will be scaled by the same number, but always remains positive.

  ## Examples

        iex>  m1 = Measurements.time(543, :millisecond) |> Measurements.Value.add_error(3, :millisecond)
        iex> Measurements.scale(m1, 10)
        %Measurements.Value{
          value: 5430,
          unit: :millisecond,
          error: 30
        }

  """
  def scale(m1, n) when is_integer(n) do
    Value.new(m1[:value] * n, m1[:unit], abs(m1.error * n))
  end

  @doc """
  The difference of two measurements, with implicit unit conversion.

  Only measurements with the same unit dimension will work.
  Error will be propagated (ie compounded).

  ## Examples

      iex>  m1 = Measurements.time(42, :second) |> Measurements.Value.add_error(1, :second)
      iex>  m2 = Measurements.time(543, :millisecond) |> Measurements.Value.add_error(3, :millisecond)
      iex> Measurements.delta(m1, m2)
      %Measurements.Value{
        value: 41_457,
        unit: :millisecond,
        error: 1_003
      }

  """
  def delta(m1, m2) do
    cond do
      m1[:unit] == m2[:unit] ->
        Value.new(m1[:value] - m2[:value], m1[:unit], m1[:error] + m2[:error])

      Unit.dimension(m1[:unit]) == Unit.dimension(m2[:unit]) ->
        m1 = Value.convert(m1, m2[:unit])
        m2 = Value.convert(m2, m1[:unit])
        delta(m1, m2)

      true ->
        raise ArgumentError, message: "#{m1} and #{m2} have incompatible unit dimension"
    end
  end

  @doc """
  The ratio of two measurements, with implicit unit conversion.

  Only measurements with the same unit dimension will work, currently.
  Error will be propagated (ie relatively compounded) as an int if possible.

  ## Examples

      iex>  m1 = Measurements.time(300, :second) |> Measurements.Value.add_error(1, :second)
      iex>  m2 = Measurements.time(60_000, :millisecond) |> Measurements.Value.add_error(3, :millisecond)
      iex> Measurements.ratio(m1, m2)
      %Measurements.Value{
        value: 5,
        unit: nil,
        error: 0.01691666666666667
      }

  """
  def ratio(m1, m2) do
    cond do
      m1[:unit] == m2[:unit] ->
        # note: relative error is computed as float temporarily (quotient is supposed to always be small)
        # For error we rely on float precision. Other approximations are already made in Error propagation theory anyway.
        m1_rel_err = m1[:error] / m1[:value]
        m2_rel_err = m2[:error] / m2[:value]

        value =
          if rem(m1[:value], m2[:value]) == 0,
            do: div(m1[:value], m2[:value]),
            else: m1[:value] / m2[:value]

        error = abs(value * (m1_rel_err + m2_rel_err))

        # TODO : unit conversion via ratio...
        # TODO : maybe unit is still there, but only with a scale ??
        # TMP: force to scale 0 if unit is nil -> constant
        Value.new(value, nil, error)

      Unit.dimension(m1[:unit]) == Unit.dimension(m2[:unit]) ->
        m1 = Value.convert(m1, m2[:unit])
        m2 = Value.convert(m2, m1[:unit])
        ratio(m1, m2)

      true ->
        raise ArgumentError, message: "#{m1} and #{m2} have incompatible unit dimension"
    end
  end

  # TODO : ratio of different units, with adjustment of dimension
  # TODO : product with increase of dimension
end
