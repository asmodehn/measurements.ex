defmodule Measurements.Unit.Dimension do
  @moduledoc """
    `Measurements.Dimension` deals with the dimension of a unit and related conversion
  """

  alias Measurements.Unit.{
    Time,
    Length,
    Mass,
    Current,
    Temperature,
    Substance,
    Lintensity,
    Derived
  }

  # TODO: use module atom instead ???
  defstruct time: 0,
            length: 0,
            mass: 0,
            current: 0,
            temperature: 0,
            substance: 0,
            lintensity: 0

  @typedoc "Dimension Type"
  @type t :: %__MODULE__{
          time: integer,
          length: integer,
          mass: integer,
          current: integer,
          temperature: integer,
          substance: integer,
          lintensity: integer
        }

  def new() do
    %__MODULE__{}
  end

  def with_time(%__MODULE__{} = d, n) do
    %{d | time: d.time + n}
  end

  def with_length(%__MODULE__{} = d, n) do
    %{d | length: d.length + n}
  end

  def with_mass(%__MODULE__{} = d, n) do
    %{d | mass: d.mass + n}
  end

  def with_current(%__MODULE__{} = d, n) do
    %{d | current: d.current + n}
  end

  def with_temperature(%__MODULE__{} = d, n) do
    %{d | temperature: d.temperature + n}
  end

  def with_substance(%__MODULE__{} = d, n) do
    %{d | substance: d.substance + n}
  end

  def with_lintensity(%__MODULE__{} = d, n) do
    %{d | lintensity: d.lintensity + n}
  end

  defdelegate sum(d1, d2), to: Witchcraft.Semigroup, as: :append
  defdelegate delta(d1, d2), to: Measurements.Additive.Group, as: :delta
  defdelegate opposite(d1), to: Measurements.Additive.Group, as: :inverse

  def module(%__MODULE__{
        time: t,
        length: 0,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      })
      when t != 0,
      do: {:ok, Time}

  def module(%__MODULE__{
        time: 0,
        length: l,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      })
      when l != 0,
      do: {:ok, Length}

  def module(%__MODULE__{
        time: 0,
        length: 0,
        mass: m,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: 0
      })
      when m != 0,
      do: {:ok, Mass}

  def module(%__MODULE__{
        time: 0,
        length: 0,
        mass: 0,
        current: c,
        temperature: 0,
        substance: 0,
        lintensity: 0
      })
      when c != 0,
      do: {:ok, Current}

  def module(%__MODULE__{
        time: 0,
        length: 0,
        mass: 0,
        current: 0,
        temperature: th,
        substance: 0,
        lintensity: 0
      })
      when th != 0,
      do: {:ok, Temperature}

  def module(%__MODULE__{
        time: 0,
        length: 0,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: s,
        lintensity: 0
      })
      when s != 0,
      do: {:ok, Substance}

  def module(%__MODULE__{
        time: 0,
        length: 0,
        mass: 0,
        current: 0,
        temperature: 0,
        substance: 0,
        lintensity: li
      })
      when li != 0,
      do: {:ok, Lintensity}

  def module(%__MODULE__{}), do: Derived
end

defimpl String.Chars, for: Measurements.Unit.Dimension do
  def to_string(%Measurements.Unit.Dimension{
        time: t,
        length: l,
        mass: m,
        current: i,
        temperature: th,
        substance: n,
        lintensity: j
      }) do
    repr = ""
    repr <> if t != 0, do: "T**#{t}", else: ""
    repr <> if l != 0, do: "L**#{l} ", else: ""
    repr <> if m != 0, do: "M**#{m} ", else: ""
    repr <> if i != 0, do: "I**#{i} ", else: ""
    repr <> if th != 0, do: "θ**#{th}", else: ""
    repr <> if n != 0, do: "N**#{n}", else: ""
    repr <> if j != 0, do: "J**#{j}", else: ""
  end
end

defimpl TypeClass.Property.Generator, for: Measurements.Unit.Dimension do
  def generate(_),
    do:
      Measurements.Unit.Dimension.new()
      |> Measurements.Unit.Dimension.with_time(Enum.random(-3..3))
      |> Measurements.Unit.Dimension.with_length(Enum.random(-3..3))
      |> Measurements.Unit.Dimension.with_mass(Enum.random(-3..3))
      |> Measurements.Unit.Dimension.with_current(Enum.random(-3..3))
      |> Measurements.Unit.Dimension.with_temperature(Enum.random(-3..3))
      |> Measurements.Unit.Dimension.with_substance(Enum.random(-3..3))
      |> Measurements.Unit.Dimension.with_lintensity(Enum.random(-3..3))
end

import TypeClass

definst Witchcraft.Semigroup, for: Measurements.Unit.Dimension do
  def append(%Measurements.Unit.Dimension{} = d1, %Measurements.Unit.Dimension{} = d2) do
    %Measurements.Unit.Dimension{
      time: d1.time + d2.time,
      length: d1.length + d2.length,
      mass: d1.mass + d2.mass,
      current: d1.current + d2.current,
      temperature: d1.temperature + d2.temperature,
      substance: d1.substance + d2.substance,
      lintensity: d1.lintensity + d2.lintensity
    }
  end
end

definst Witchcraft.Monoid, for: Measurements.Unit.Dimension do
  def empty(_d) do
    %Measurements.Unit.Dimension{}
  end
end

definst Measurements.Additive.Group, for: Measurements.Unit.Dimension do
  def inverse(%Measurements.Unit.Dimension{} = d) do
    d
    |> Map.update!(:time, &(-&1))
    |> Map.update!(:length, &(-&1))
    |> Map.update!(:mass, &(-&1))
    |> Map.update!(:current, &(-&1))
    |> Map.update!(:temperature, &(-&1))
    |> Map.update!(:substance, &(-&1))
    |> Map.update!(:lintensity, &(-&1))
  end
end
