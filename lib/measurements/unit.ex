defmodule Measurements.Unit do
  @moduledoc """
  Documentation for `Measurements.Unit`.

  A unit is represented by an atom. Ref: https://en.wikipedia.org/wiki/International_System_of_Units

  There exist multiple submodules defining the various units:
  - `Time`
  - TODO !!

  Internally, a unit relies on `Scale` and `Dimension` to determine:
  - which conversion is allowed or not.
  - which unit is better suited to a value.

  But a user does not need to know about it, it will be managed automatically, to minimize loss of precision,
  and keep the Measurement value in the integer range as much as possible.

  ## Examples

      iex> Measurements.Unit.time(:second)
      {:ok, :second}

      iex> Measurements.Unit.min(:second, :nanosecond)
      {:ok, :nanosecond}

      iex> {:ok, converter} = Measurements.Unit.convert(:second, :millisecond)
      iex> converter.(42)
      42_000

  """

  require Measurements.Unit.Time
  require Measurements.Unit.Length

  alias Measurements.Unit.Time
  alias Measurements.Unit.Length
  # alias Measurements.Unit.Derived

  alias Measurements.Unit.Scale
  alias Measurements.Unit.Dimension

  alias Measurements.Unit.Parser

  @typedoc "Unit Type"
  @type t :: atom()

  @type value :: integer()

  @doc """
  Normalizes a custom time unit to a known one.
  """
  @spec time(atom) :: {:ok, t} | {:error, (value -> value), t}
  def time(unit) do
    if unit in Time.__units() or Time.__alias(unit) do
      new(unit)
      # Time.unit(
      #   Time.scale(unit),
      #   Time.dimension(unit)
      # )
    else
      {:error, :not_a_supported_time_unit}
    end
  end

  @doc """
  Normalizes a custom length unit to a known one
  """
  @spec length(atom) :: {:ok, t} | {:error, (value -> value), t}
  def length(unit) do
    if unit in Length.__units() or Length.__alias(unit) do
      new(unit)
      # # let the Length module handle it
      # Length.unit(
      #   Length.scale(unit),
      #   Length.dimension(unit)
      # )
    else
      {:error, :not_a_supported_length_unit}
    end
  end

  @doc """
  Returns the module where this unit is defined.

  Indicates which implementation to call for normalization, conversion, etc.
  """
  @spec module(atom) :: atom
  def module(unit) do
    cond do
      is_nil(unit) -> {:ok, nil}
      unit in Time.__units() -> {:ok, Time}
      unit in Length.__units() -> {:ok, Length}
      # nil if not found in aliases
      Time.__alias(unit) -> {:ok, Time}
      Length.__alias(unit) -> {:ok, Length}
      true -> {:error, :unit_module_not_found}
    end
  end

  @doc """
  Normalizes a known unit, of any dimension
  """
  @spec new(atom) :: {:ok, t} | {:error, (value -> value), t}
  def new(nil), do: {:ok, nil}

  def new(unit) when is_atom(unit) do
    # parse and regen
    case Parser.parse(unit) do
      {:ok, scale, dimension} -> new(%{scale | dimension: dimension})
      {:error, reason} -> raise RuntimeError, message: reason
    end

    # case module(unit) do
    #   {:ok, unit_module} ->
    #     unit_module.unit(
    #       unit_module.scale(unit),
    #       unit_module.dimension(unit)
    #     )

    #   {:error, :unit_module_not_found} ->
    #     raise RuntimeError, message: "#{unit} not found in Measurements.Unit.*"
    # end
  end

  def new(%Scale{dimension: _d} = s) do
    {unit_atom, scale} = Parser.to_unit(s)

    if scale == %Scale{} do
      {:ok, unit_atom}
    else
      {:error, Scale.convert(scale), unit_atom}
    end
  end

  # To retrieve a unit atom from a scale and dimension
  # OLD API backward compat
  def new(%Scale{dimension: %Dimension{}} = s, %Dimension{} = d) do
    new(%{s | dimension: d})
  end

  # def new(%Scale{} = s, %Dimension{time: t, length: 0} = d) when t != 0 do
  #   Time.unit(s, d)
  # end

  # def new(%Scale{} = s, %Dimension{time: 0, length: l} = d) when l != 0 do
  #   Length.unit(s, d)
  # end

  # # else it is a derived unit

  # def new(%Scale{} = s, %Dimension{} = d) do
  #   Derived.unit(s, d)
  # end

  @doc """
  The dimension of the unit
  """
  # TODO :review hte API, alwys go with a Scale...
  @spec dimension(atom) :: {:ok, Dimension.t()} | {:error, term}
  def dimension(nil), do: {:ok, %Dimension{}}

  def dimension(unit) do
    case Parser.parse(unit) do
      {:ok, _scale, dimension} -> {:ok, dimension}
      {:error, reason} -> raise RuntimeError, message: reason
    end
  end

  @doc """
  """
  # TODO :review hte API, alwys go with a Dimension...
  @spec scale(atom) :: {:ok, Scale.t()} | {:error, term}
  def scale(nil), do: {:ok, %Scale{}}

  def scale(unit) do
    case Parser.parse(unit) do
      {:ok, scale, _dimension} -> {:ok, scale}
      {:error, reason} -> raise RuntimeError, message: reason
    end
  end

  @doc """
  Conversion algorithm from a unit to another.

  Will find out which dimension the unnit belongs to, and if a conversion is possible.
  """
  @spec convert(t, t) :: {:ok, (value -> value)} | {:error, String.t()}
  def convert(from_unit, to_unit) when from_unit == to_unit do
    {:ok, &Function.identity/1}
  end

  def convert(from_unit, to_unit) do
    {:ok, target_dim} = dimension(to_unit)

    case dimension(from_unit) do
      {:ok, ^target_dim} ->
        {:ok, from} = scale(from_unit)
        {:ok, to} = scale(to_unit)
        {:ok, Scale.convert(Scale.ratio(from, to))}

      {:ok, _another_dim} ->
        {:error, :incompatible_dimension}

      {:error, what} ->
        {:error, what}
    end
  end

  @doc """
  finds out, for two units of the same dimension, which unit is less (in scale) than the other.
  This means the returned unit will be the most precise
  """
  @spec min(t, t) :: t
  def min(nil, nil), do: {:ok, nil}

  def min(u1, u2) do
    {:ok, dim2} = dimension(u2)

    case dimension(u1) do
      {:ok, ^dim2} ->
        {:ok, s1} = scale(u1)
        {:ok, s2} = scale(u2)
        {:ok, if(s1 < s2, do: u1, else: u2)}

      {:ok, _another_dim} ->
        {:error, :incompatible_dimension}

      {:error, what} ->
        {:error, what}
    end
  end

  @doc """
  finds out, for two units of the same dimension, which unit is more (in scale) than the other.
  This means the returned unit will be the least precise
  """
  @spec max(t, t) :: t
  def max(nil, nil), do: {:ok, nil}

  def max(u1, u2) do
    {:ok, dim2} = dimension(u2)

    case dimension(u1) do
      {:ok, ^dim2} ->
        {:ok, s1} = scale(u1)
        {:ok, s2} = scale(u2)
        {:ok, if(s1 >= s2, do: u1, else: u2)}

      {:ok, _another_dim} ->
        {:error, :incompatible_dimension}

      {:error, what} ->
        {:error, what}
    end
  end

  @spec to_string(atom) :: String.t()
  def to_string(nil), do: ""

  # TODO : handle unit_#{exponent} !
  # TODO : handle per_unit !
  def to_string(unit) do
    {:ok, scale} = scale(unit)
    {:ok, unit_module} = Scale.module(scale)
    # {:ok, unit_module} = module(unit |> IO.inspect()) |> IO.inspect()
    unit_module.to_string(unit)
  end

  @doc """
  Since unit is an atom, protocol cannot dispatch on it.
  However we can rely on scale and dimension of the unit
  """
  @spec product(t, t) :: {:ok, (value -> value)} | {:error, String.t()}
  def product(u1, u2) do
    with {^u1, {:ok, s1}, {:ok, d1}} <-
           {u1, Measurements.Unit.scale(u1), Measurements.Unit.dimension(u1)},
         {^u2, {:ok, s2}, {:ok, d2}} <-
           {u2, Measurements.Unit.scale(u2), Measurements.Unit.dimension(u2)} do
      # |> IO.inspect()
      prod_dim = Measurements.Unit.Dimension.sum(d1, d2)
      # |> IO.inspect()
      prod_scale = Measurements.Unit.Scale.prod(s1, s2)
      # |> IO.inspect()
      # prod_dim_scale= Measurements.Unit.scale(prod_dim)
      # |> IO.inspect()

      Measurements.Unit.new(prod_scale)
    else
      {unit, {:error, reason}, {:ok, d}} ->
        raise ArgumentError,
          message: "#{unit} has a dimension of #{d} but scale/1 gives error: #{reason}"

      {unit, {:ok, s}, {:error, reason}} ->
        raise ArgumentError,
          message: "#{unit} has a scale of #{s} but dimension/1 gives error: #{reason}"

      {unit, {:error, reason_s}, {:error, reason_d}} ->
        raise ArgumentError,
          message:
            "#{unit} dimension/1 gives error: #{reason_d} and scales/1 gives error: #{reason_s}"
    end
  end

  @doc """
  Sinc unit is an atom, protocol cannot dispatch on it.
  However we can rely on scale and dimension of the unit
  """
  @spec ratio(t, t) :: t
  def ratio(u1, u2) do
    with {^u1, {:ok, s1}, {:ok, d1}} <-
           {u1, Measurements.Unit.scale(u1), Measurements.Unit.dimension(u1)},
         {^u2, {:ok, s2}, {:ok, d2}} <-
           {u2, Measurements.Unit.scale(u2), Measurements.Unit.dimension(u2)} do
      Measurements.Unit.new(
        Measurements.Unit.Scale.ratio(s1, s2),
        Measurements.Unit.Dimension.delta(d1, d2)
      )
    else
      {unit, {:error, reason}, {:ok, d}} ->
        raise ArgumentError,
          message: "#{unit} has a dimension of #{d} but scale/1 gives error: #{reason}"

      {unit, {:ok, s}, {:error, reason}} ->
        raise ArgumentError,
          message: "#{unit} has a scale of #{s} but dimension/1 gives error: #{reason}"

      {unit, {:error, reason_s}, {:error, reason_d}} ->
        raise ArgumentError,
          message:
            "#{unit} dimension/1 gives error: #{reason_d} and scales/1 gives error: #{reason_s}"
    end
  end
end
