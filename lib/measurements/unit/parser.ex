defmodule Measurements.Unit.Parser.TMPAPI do
  @moduledoc false

  # Internal API

  alias Measurements.Unit.Time
  alias Measurements.Unit.Length

  def scale(prefix) do
    case prefix do
      "atto" -> -18
      "femto" -> -15
      "pico" -> -12
      "nano" -> -9
      "micro" -> -6
      "milli" -> -3
      "" -> 0
      "kilo" -> 3
      "mega" -> 6
      "giga" -> 9
      "tera" -> 12
      "peta" -> 15
      "exa" -> 18
    end
  end

  def unit(str) do
    case str |> Enum.join("") |> String.replace_suffix("s", "") do
      "second" -> {Time, 1}
      "hertz" -> {Time, -1}
      "meter" -> {Length, 1}
    end
  end

  def exponent(exp_str) when is_list(exp_str) do
    # from charlist to string
    str = List.to_string(exp_str)
    # parse to integer
    {i, ""} = Integer.parse(str)
    i
  end

  def invert(per_str), do: if(per_str == "", do: 1, else: -1)
end

defmodule Measurements.Unit.Parser do
  @moduledoc """
  This is a Parser for unit atoms, once converted to string for unit computation.

  This is the reference in the code about what unit is accepted and how it is represented internally.

  Indeed, the accepted syntax, and its semantics via mapped functions, is clearly explicited in this module.

  Therefore we must eventually verify via tests that:
  - any generatable unit is parsable (easy), 
  - every parseable unit is generateable (harder) 

  """
  import NimbleParsec

  alias Measurements.Unit.Parser.TMPAPI

  scale_prefix =
    optional(
      choice([
        string("atto"),
        string("femto"),
        string("pico"),
        string("nano"),
        string("micro"),
        string("milli"),
        string("kilo"),
        string("mega"),
        string("giga"),
        string("tera"),
        string("peta"),
        string("exa"),
        string("")
      ])
    )
    |> map({TMPAPI, :scale, []})
    |> label(
      "scale prefix, among these: atto, femto, pico, nano, micro, milli, kilo, mega, giga, tera, peta, exa, or just nothing"
    )

  invert =
    choice([string("per_"), string("")])
    |> map({TMPAPI, :invert, []})

  core_unit =
    choice([
      string("second") |> optional(string("s")),
      string("hertz"),
      string("meter") |> optional(string("s"))
    ])
    |> reduce({TMPAPI, :unit, []})
    |> label(
      "optional prefix \"per_\" with a core unit among these: \"second\", \"hertz\", \"meter\""
    )

  exponent =
    choice([
      ignore(string("_")) |> concat(integer(1)),
      # default to dimension one (integer), since unit is present !
      string("") |> replace(1)
    ])
    |> label(
      "exponent integer, always positive, separated by a leading '_' or nothing for implicit 1"
    )

  defparsec(
    :unit,
    repeat(
      invert
      |> concat(scale_prefix)
      |> concat(core_unit)
      |> concat(exponent)
      |> ignore(optional(string("_")))
    )
  )

  alias Measurements.Unit.Scale
  alias Measurements.Unit.Dimension

  @spec parse(atom) :: {:ok, Scale.t(), Dimension.t()} | {:error, term}
  def parse(unit) when is_atom(unit) do
    {:ok, scale_dim_list, "", _, _, _} = unit(Atom.to_string(unit))

    Enum.chunk_every(scale_dim_list, 4)
    |> Enum.map(fn
      [inv, scale, {mod, pow}, exp] ->
        {%{Scale.new(scale * exp * inv) | dimension: mod.with_dimension(exp * pow * inv)},
         mod.with_dimension(exp * pow * inv)}
    end)
    |> Enum.reduce({:ok, Scale.new(), Dimension.new()}, fn
      {s, d}, {:ok, accs, accd} ->
        {:ok, %{Scale.prod(accs, s) | dimension: Dimension.sum(accd, d)}, Dimension.sum(accd, d)}
    end)

    # TODO :return error when parse is not possible
  end

  @spec prefix(Scale.t(), atom) :: {String.t(), Scale.t()}

  def prefix(%Scale{} = s, :time), do: prefix(s, s.dimension.time)
  def prefix(%Scale{} = s, :length), do: prefix(s, s.dimension.length)
  def prefix(%Scale{} = s, :mass), do: prefix(s, s.dimension.mass)
  def prefix(%Scale{} = s, :current), do: prefix(s, s.dimension.current)
  def prefix(%Scale{} = s, :temperature), do: prefix(s, s.dimension.temperature)
  def prefix(%Scale{} = s, :substance), do: prefix(s, s.dimension.substance)
  def prefix(%Scale{} = s, :lintensity), do: prefix(s, s.dimension.lintensity)

  def prefix(%Scale{magnitude: m} = s, dims) when is_integer(dims) do
    cond do
      m >= 18 * dims -> {"exa", %{s | magnitude: m - 18 * dims}}
      m >= 15 * dims -> {"peta", %{s | magnitude: m - 15 * dims}}
      m >= 12 * dims -> {"tera", %{s | magnitude: m - 12 * dims}}
      m >= 9 * dims -> {"giga", %{s | magnitude: m - 9 * dims}}
      m >= 6 * dims -> {"mega", %{s | magnitude: m - 6 * dims}}
      m >= 3 * dims -> {"kilo", %{s | magnitude: m - 3 * dims}}
      m >= 0 -> {"", s}
      m >= -3 * dims -> {"milli", %{s | magnitude: m + 3 * dims}}
      m >= -6 * dims -> {"micro", %{s | magnitude: m + 6 * dims}}
      m >= -9 * dims -> {"nano", %{s | magnitude: m + 9 * dims}}
      m >= -12 * dims -> {"pico", %{s | magnitude: m + 12 * dims}}
      m >= -15 * dims -> {"femto", %{s | magnitude: m + 15 * dims}}
      true -> {"atto", %{s | magnitude: m + 18 * dims}}
    end
  end

  @doc """
  A straight forward way to generate a unit atom. 
  This might not be the one desired however, since scale can be shifted between the various unit dimensions (eg. millimeter per second /vs/ meter per kilosecond)

  Choice is a matter of preference and is left to the user, `Unit.equal?` should be used to check for unit equality and replace the atom where needed during computations.

  """
  @spec to_unit(Scale.t(), String.t()) :: {atom, Scale.t()}
  def to_unit(scale, acc \\ "")

  def to_unit(
        %Scale{
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
        acc
      ) do
    # convert to readable unit when appropriate -> very special cases
    # TODO : Regex to cover these cases ?
    final_acc =
      acc
      |> String.replace_prefix("per_second", "hertz")
      |> String.replace_prefix("per_kilosecond", "kilohertz")
      |> String.replace_prefix("per_gigasecond", "gigahertz")
      |> String.replace_prefix("per_megasecond", "megahertz")

    {String.to_atom(final_acc), s}
  end

  # REMEMBER to order these by unit priority when naming a derived unit...
  def to_unit(%Scale{dimension: %Dimension{length: l} = dim} = scale, acc) when l < 0,
    do: to_unit(%{scale | dimension: %{dim | length: -l}}, compose_acc_next(acc, "per"))

  def to_unit(%Scale{magnitude: m, dimension: %Dimension{length: l} = dim} = scale, acc)
      when l > 0 do
    mag_rem = Integer.mod(m, l)

    mag_adjusted_scale =
      if mag_rem == 0 do
        scale
      else
        # move rem to coef
        Scale.mag_down(scale, mag_rem)
      end

    # => rem is always 0
    # -> quotient is always integer (no float)

    {unit_prefix, new_scale} = prefix(mag_adjusted_scale, :length)
    acc_next = compose_acc_next(acc, unit_prefix <> "meter" <> if(l > 1, do: "_#{l}", else: ""))
    to_unit(%{new_scale | dimension: %{dim | length: 0}}, acc_next)
  end

  def to_unit(%Scale{dimension: %Dimension{time: t} = dim} = scale, acc) when t < 0,
    do: to_unit(%{scale | dimension: %{dim | time: -t}}, compose_acc_next(acc, "per"))

  def to_unit(%Scale{magnitude: m, dimension: %Dimension{time: t} = dim} = scale, acc)
      when t > 0 do
    mag_rem = Integer.mod(m, t)

    mag_adjusted_scale =
      if mag_rem == 0 do
        scale
      else
        # move rem to coef
        Scale.mag_down(scale, mag_rem)
      end

    # => rem is always 0
    # -> quotient is always integer (no float)

    {unit_prefix, new_scale} = prefix(mag_adjusted_scale, :time)
    acc_next = compose_acc_next(acc, unit_prefix <> "second" <> if(t > 1, do: "_#{t}", else: ""))
    to_unit(%{new_scale | dimension: %{dim | time: 0}}, acc_next)
  end

  # TODO : better strategy for this ???
  defp compose_acc_next(acc, next) when acc == "", do: next

  defp compose_acc_next(acc, next) do
    if(String.ends_with?(acc, "_"), do: acc, else: acc <> "_") <> next
  end
end
