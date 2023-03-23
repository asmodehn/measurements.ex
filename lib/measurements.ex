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
  alias Measurements.Measurement

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

  defdelegate convert(m, unit), to: Measurement

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
  defdelegate sum(m1, m2), to: Measurements.Additive.Semigroup, as: :sum
  # def sum(%module{} = m1, m2), do: module.sum(m1, m2)

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
  def scale(%module{} = m, n), do: module.scale(m, n)

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

  def delta(%module{} = m1, m2), do: module.delta(m1, m2)

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
  def ratio(%module{} = m1, m2), do: module.ratio(m1, m2)

  # TODO : ratio of different units, with adjustment of dimension
  # TODO : product with increase of dimension
end
