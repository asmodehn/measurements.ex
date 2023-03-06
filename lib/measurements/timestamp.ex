defmodule Measurements.Timestamp do
  # hiding Elixir.System to make sure we do not inadvertently use it
  alias Measurements.System
  # hiding Elixir.Process to make sure we do not inadvertently use it
  alias Measurements.Process
  # hiding Elixir.Process to make sure we do not inadvertently use it
  alias Measurements.Node

  alias Measurements.Unit
  alias Measurements.Value

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
          vm_offset: integer()
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
   Otherwise vm_offset is taken into account.
  """
  def delta(%__MODULE__{} = lts, %__MODULE__{} = previous_lts)
      when lts.node == previous_lts.node and lts.unit == previous_lts.unit do
    Measurements.time(
      lts.monotonic - previous_lts.monotonic,
      lts.unit
    )
  end

  def delta(%__MODULE__{} = lts, %__MODULE__{} = previous_lts)
      when lts.unit == previous_lts.unit do
    Measurements.time(
      lts.monotonic + lts.vm_offset - previous_lts.monotonic - previous_lts.vm_offset,
      lts.unit
    )
  end

  def delta(%__MODULE__{} = lts, %__MODULE__{} = previous_lts) do
    if System.convert_time_unit(1, lts.unit, previous_lts.unit) == 0 do
      # lts.unit is most precise
      delta(lts, convert(previous_lts, lts.unit))
    else
      # previous_lts.unit is most precise
      delta(convert(lts, previous_lts.unit), lts)
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
    dt = div(abs(delta(lts_a, lts_b).value), 2)
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
  def convert(%__MODULE__{} = m, unit, :force), do: convert(m, unit, :system)
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

  @behaviour Value.Behaviour
  # TODO : protocol instead ??
  @impl Value.Behaviour
  def value(%__MODULE__{} = ts), do: system_time(ts).value
  @impl Value.Behaviour
  def error(%__MODULE__{} = ts), do: ts.error
  @impl Value.Behaviour
  def unit(%__MODULE__{} = ts), do: ts.unit

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
  @spec convert(t, Unit.t()) :: t

  def convert(%__MODULE__{unit: u} = m, unit) when u == unit, do: m

  def convert(%__MODULE__{} = m, unit) do
    case Unit.min(m.unit, unit) do
      {:ok, min_unit} ->
        # if Unit.min is successful, conversion will always work.
        convert(m, min_unit, :force)

      # no conversion possible, just ignore it
      {:error, :incompatible_dimension} ->
        raise ArgumentError, message: "#{unit} dimension is not compatible with #{m.unit}"
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
  def sum(%__MODULE__{} = v1, %__MODULE__{} = v2), do: Value.sum(system_time(v1), system_time(v2))
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
