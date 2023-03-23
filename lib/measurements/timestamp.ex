defmodule Measurements.Timestamp do
  @moduledoc """

  A timestamp, as local a measurement.
  """

  # hiding Elixir.System to make sure we do not inadvertently use it
  alias Measurements.System
  # hiding Elixir.Process to make sure we do not inadvertently use it
  alias Measurements.Process
  # hiding Elixir.Process to make sure we do not inadvertently use it
  alias Measurements.Node

  alias Measurements.Unit
  alias Measurements.Value
  alias Measurements.Measurement

  @enforce_keys [:node, :monotonic, :unit, :vm_offset]
  defstruct node: nil,
            monotonic: nil,
            unit: nil,
            vm_offset: nil,
            error: 0

  @typedoc "Timetamp struct"
  @type t() :: %__MODULE__{
          node: String.t(),
          monotonic: integer(),
          unit: System.time_unit(),
          vm_offset: integer(),
          error: non_neg_integer()
        }

  # TODO : unify with Measurement struct...
  def now(unit \\ System.Extra.native_time_unit()) do
    %__MODULE__{
      node: Node.self(),
      unit: unit,
      monotonic: System.monotonic_time(unit),
      vm_offset: System.time_offset(unit)
    }
  end

  @spec system_time(t()) :: Value.t()
  def system_time(%__MODULE__{} = lts) do
    Measurements.time(lts.monotonic + lts.vm_offset, lts.unit)
  end

  @spec system_time(t(), System.time_unit()) :: Value.t()
  def system_time(%__MODULE__{} = lts, unit) do
    System.convert_time_unit(lts.monotonic + lts.vm_offset, lts.unit, unit)
    |> Measurements.time(unit)
  end

  @spec monotonic_time(t()) :: Value.t()
  def monotonic_time(%__MODULE__{} = lts) do
    Measurements.time(lts.monotonic, lts.unit)
  end

  @spec time_offset(t()) :: Value.t()
  def time_offset(%__MODULE__{} = lts) do
    Measurements.time(lts.vm_offset, lts.unit)
  end

  @spec monotonic_time(t(), System.time_unit()) :: Value.t()
  def monotonic_time(%__MODULE__{} = lts, unit) do
    System.convert_time_unit(lts.monotonic, lts.unit, unit)
    |> Measurements.time(unit)
  end

  @spec time_offset(t(), System.time_unit()) :: Value.t()
  def time_offset(%__MODULE__{} = lts, unit) do
    System.convert_time_unit(lts.vm_offset, lts.unit, unit)
    |> Measurements.time(unit)
  end

  @doc """
   Compute the time elapsed between two timestamps.
   CAREFUL : IF both measurements occured on the same node, this is using only monotonic_time.
   Otherwise it is like any other measurement value, and therefore vm_offset is taken into account.
  """
  def duration(%__MODULE__{} = lts, %__MODULE__{} = previous_lts)
      when lts.node == previous_lts.node and lts.unit == previous_lts.unit do
    Measurements.time(
      lts.monotonic - previous_lts.monotonic,
      lts.unit
    )
  end

  def duration(%__MODULE__{} = lts, %__MODULE__{} = previous_lts)
      when lts.node == previous_lts.node do
    if System.convert_time_unit(1, lts.unit, previous_lts.unit) == 0 do
      # lts.unit is most precise
      duration(lts, Measurement.convert(previous_lts, lts.unit))
    else
      # previous_lts.unit is most precise
      duration(Measurement.convert(lts, previous_lts.unit), lts)
    end
  end

  # TODO :is this a delta (as with group structure ?) or is it useless, as m is always a timestamp ??
  def duration(%__MODULE__{} = v1, m) do
    # Note:adding something that is not a timestamp produce a usual value.
    if v1.unit ==
         Measurement.unit(m) do
      Value.new(
        Measurement.value(v1) - Measurement.value(m),
        v1.unit,
        v1.error + Measurement.error(m)
      )
    else
      with {:ok, s1} <- Unit.scale(v1.unit),
           {:ok, s2} <- Unit.scale(Measurement.unit(m)) do
        if s1.dimension == s2.dimension do
          m1 = Measurement.convert(v1, Measurement.unit(m))
          m2 = Measurement.convert(m, v1.unit)
          duration(m1, m2)
        else
          raise ArgumentError, message: "#{v1} and #{m} have incompatible unit dimension"
        end
      end
    end
  end

  # def after_a_while(%__MODULE__{} = lts, %Time.Value{} = tv) do
  #   converted_tv = Time.Value.convert(tv, lts.unit)

  #   %__MODULE__{
  #     unit: lts.unit,
  #     # guessing monotonic value then. remove possible error to be conservative.
  #     monotonic: lts.monotonic + converted_tv.value - converted_tv.error,
  #     # just a guess
  #     vm_offset: lts.vm_offset
  #   }
  # end

  def between(%__MODULE__{} = lts_a, %__MODULE__{} = lts_b)
      when lts_a.node == lts_b.node and lts_a.unit == lts_b.unit do
    # estimating error as half the duration, no matter the order of the arguments.
    dt = div(abs(duration(lts_a, lts_b).value), 2)
    # find the most recent timestamp with monotonic time.
    {recent, previous} =
      if lts_a.monotonic >= lts_b.monotonic, do: {lts_a, lts_b}, else: {lts_b, lts_a}

    %__MODULE__{
      node: recent.node,
      unit: recent.unit,
      monotonic: previous.monotonic + dt,
      # CAREFUL: we loose precision and introduce errors here...
      # AND we ignore vm offset changes (small / same node only)!
      vm_offset: recent.vm_offset,
      error: dt
    }
  end

  # # TODO : make the rturn type a time value (again) so that we track long response time as a potential measurement error...
  # def middle_stamp_estimate(%__MODULE__{} = lts_before, %__MODULE__{} = lts_after)
  #     when lts_before.unit == lts_after.unit do

  #   %__MODULE__{
  #     unit: lts_before.unit,
  #     # we use floor_div here to always round downwards (no matter where 0 happens to be)
  #     # monotonic constraints should be set on the stream to avoid time going backwards
  #     monotonic: Integer.floor_div(lts_before.monotonic + lts_after.monotonic, 2),
  #     # CAREFUL: we loose precision and introduce errors here...
  #     # AND we suppose the vm offset only changes linearly...
  #     vm_offset: Integer.floor_div(lts_before.vm_offset + lts_after.vm_offset, 2)
  #     # BUT we are NOT interested in tracking error in local timestamps.
  #   }
  # end

  def convert(%__MODULE__{} = lts, unit, :system) do
    nu = System.Extra.normalize_time_unit(unit)

    %__MODULE__{
      node: lts.node,
      unit: nu,
      monotonic: System.convert_time_unit(lts.monotonic, lts.unit, nu),
      vm_offset: System.convert_time_unit(lts.vm_offset, lts.unit, nu),
      error: System.convert_time_unit(lts.error, lts.unit, nu)
    }
  end

  # Covering common behaviour with Value
  # def convert(%__MODULE__{} = m, unit, :force), do: convert(m, unit, :system)
  # {:ok, converter} = Unit.convert(m.unit, unit)
  #   %__MODULE__{
  #         node: m.node,
  #         monotonic: converter.(m.monotonic),
  #         unit: min_unit,
  #         vm_offset: converter.(m.vm_offset),
  #         error: converter.(m.error)
  #       }
  # end

  @spec wake_up_at(t()) :: t()
  def wake_up_at(%__MODULE__{} = lts) do
    bef = now(lts.unit)

    # difference (ms)
    to_wait =
      System.convert_time_unit(lts.monotonic, lts.unit, :millisecond) -
        System.convert_time_unit(bef.monotonic, bef.unit, :millisecond)

    # SIDE_EFFECT !
    # and always return current timestamp, since we have to measure it anyway...
    if to_wait > 0 do
      Process.sleep(to_wait)
      now(lts.unit)
    else
      # lets avoid another probably useless System call
      bef
    end
  end

  # @doc """
  # The sum of two timestamps, with implicit unit conversion.

  # Only measurements with the same unit dimension will work.
  # Error will be propagated.

  # ## Examples

  #     iex>  m1 = Measurements.time(42, :second) |> Measurements.Value.add_error(1, :second)
  #     iex>  m2 = Measurements.time(543, :millisecond) |> Measurements.Value.add_error(3, :millisecond)
  #     iex> Measurements.sum(m1, m2)
  #     %Measurements.Value{
  #       value: 42_543,
  #       unit: :millisecond,
  #       error: 1_003
  #     }

  # """

  # PROBLEM : not associative ??

  # def sum(%__MODULE__{} = v1, %__MODULE__{} = v2)
  #     when v1.node == v2.node and v1.unit == v2.unit do
  #   %__MODULE__{
  #     node: v1.node,
  #     monotonic: v1.monotonic + v2.monotonic,
  #     unit: v1.unit,
  #     # averaging the offset for the sum
  #     vm_offset: div(v1.vm_offset + v2.vm_offset, 2),
  #     # adding offset difference as potential error
  #     error: v1.error + v2.error + abs(v1.vm_offset - v2.vm_offset)
  #   }
  # end

  # def sum(%__MODULE__{} = lts1, %__MODULE__{} = lts2) when lts1.node == lts2.node do
  #   if System.convert_time_unit(1, lts1.unit, lts2.unit) == 0 do
  #     # lts1.unit is most precise
  #     sum(lts1, Measurement.convert(lts2, lts1.unit))
  #   else
  #     # lts2.unit is most precise
  #     sum(Measurement.convert(lts1, lts2.unit), lts1)
  #   end
  # end

  @doc """
  The sum of a timestamp with a measurement (timestamp or other), with implicit unit conversion.

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
  def sum(%__MODULE__{} = v1, m) do
    if v1.unit ==
         Measurement.unit(m) do
      # Note:adding something that is not a timstamp produce a usual value.
      Value.new(
        Measurement.value(v1) + Measurement.value(m),
        v1.unit,
        v1.error + Measurement.error(m)
      )
    else
      with {:ok, s1} <- Unit.scale(v1.unit),
           {:ok, s2} <- Unit.scale(Measurement.unit(m)) do
        if s1.dimension == s2.dimension do
          v1 = Measurement.convert(v1, Measurement.unit(m))
          m = Measurement.convert(m, v1.unit)
          sum(v1, m)
        else
          raise ArgumentError, message: "#{v1} and #{m} have incompatible unit dimension"
        end
      end
    end

    # |> IO.inspect()
  end

  # Note: scale and ratio are intentionally not supported by local timestamps.
end

defimpl Measurements.Measurement, for: Measurements.Timestamp do
  def value(%Measurements.Timestamp{} = ts), do: Measurements.Timestamp.system_time(ts).value

  def error(%Measurements.Timestamp{} = ts), do: ts.error

  def unit(%Measurements.Timestamp{} = ts), do: ts.unit

  @doc """
  Convert the measurement to the new unit, if the new unit is more precise.

  This will pick the most precise between the measurement's unit and the new unit.
  Then it will convert the measurement to the chosen unit.

  If no conversion is possible, the original measurement is returned.

  ## Examples
      #TODO : with timestamp now and mocks !
      # iex> Measurements.Timestamp.new(42, :second) |> Measurements.Timestamp.convert(:millisecond)
      # %Measurements.Timestamp{value: 42_000, unit: :millisecond, error: 1_000}

      # iex> Measurements.Timestamp.new(42, :millisecond) |> Measurements.Timestamp.convert(:second)
      # %Measurements.Timestamp{value: 42, unit: :millisecond, error: 1}

  """
  @spec convert(Measurements.Timestamp.t(), Measurements.Unit.t()) :: Measurements.Timestamp.t()

  def convert(%Measurements.Timestamp{unit: u} = m, unit) when u == unit, do: m

  def convert(%Measurements.Timestamp{} = m, unit) do
    case Measurements.Unit.min(m.unit, unit) do
      {:ok, min_unit} ->
        # if Unit.min is successful, conversion will always work.
        Measurements.Timestamp.convert(m, min_unit, :system)

      # no conversion possible, just ignore it
      {:error, :incompatible_dimension} ->
        raise ArgumentError, message: "#{unit} dimension is not compatible with #{m.unit}"
    end
  end
end

defimpl String.Chars, for: Measurements.Timestamp do
  def to_string(%Measurements.Timestamp{} = lts) do
    # TODO: maybe have a more systematic / global way to manage time unit ??
    # to something that is immediately parseable ? some sigil ??
    # some existing physical unit library ?

    # delegating to Measurement... good or bad idea ?
    "#{Measurements.Timestamp.system_time(lts)}-#{Node.self()}"
    # TODO : find cluster identifier, rather than node 
    # the vm_offset is already managing time deviation between nodes, and we dont expose it.
    # => the timestamp is the **cluster** timestamp.
  end
end

import TypeClass

defimpl TypeClass.Property.Generator, for: Measurements.Timestamp do
  require Measurements.Unit.Time
  require Measurements.Unit.Length

  def generate(_),
    do: %Measurements.Timestamp{
      node: Enum.random([:node1@A, :node2@A, :node1@B, :node2@B]),
      monotonic: :rand.uniform(1000),
      unit: Enum.random(Measurements.Unit.Time.__units()),
      vm_offset: :rand.uniform(1000),
      error: :rand.uniform(10)
    }
end

definst Measurements.Additive.Semigroup, for: Measurements.Timestamp do
  # alias Measurements.Measurement
  # alias Measurements.Unit
  # alias Measurements.Value

  # require Unit.{Time, Length}

  # Note: sum between two timestmap as timestamp is possible only if measurements comes from the same node

  # def sum(%Measurements.Timestamp{} = ts1, %Measurements.Timestamp{} = ts2)
  # when ts1.node == ts2.node do
  #   Measurements.Timestamp.sum(ts1, ts2)
  # end

  # Note: Timestamp.sum is not associative... TODO : fix it ? possible ??

  defdelegate sum(v1, m), to: Measurements.Timestamp, as: :sum
end
