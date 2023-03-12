defmodule Measurements.Unit.Parser.TMPAPI do
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
      "per_second" -> {Time, -1}
      "second" -> {Time, 1}
      "hertz" -> {Time, -1}
      "per_hertz" -> {Time, 1}
      "meter" -> {Length, 1}
      "per_meter" -> {Length, -1}
    end
  end

  def exponent(exp_str) when is_list(exp_str) do
    # from charlist to string
    str = List.to_string(exp_str)
    # parse to integer
    {i, ""} = Integer.parse(str)
    i
  end
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

  core_unit =
    optional(string("per_"))
    |> concat(
      choice([
        string("second") |> optional(string("s")),
        string("hertz"),
        string("meter") |> optional(string("s"))
      ])
    )
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
      scale_prefix
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

    Enum.chunk_every(scale_dim_list, 3)
    |> Enum.map(fn
      [scale, {mod, pow}, exp] -> {Scale.new(scale * exp), mod.with_dimension(exp * pow)}
    end)
    |> Enum.reduce({:ok, Scale.new(), Dimension.new()}, fn
      {s, d}, {:ok, accs, accd} -> {:ok, Scale.prod(accs, s), Dimension.sum(accd, d)}
    end)

    # TODO :return error when parse is not possible
  end

  @doc """
  A straight forward way to generate a unit atom. 
  This might not be the one desired however, since scale can be shifted between the various unit dimensions.

  Choice is a matter of preference and is left to the user, `Unit.equal?` should be used to check for unit equality and replace the atom where needed during computations.

  """
  @spec to_unit(Scale.t(), Dimension.t(), String.t()) :: {atom, Scale.t()}
  def to_unit(scale, dim, acc \\ "")

  def to_unit(
        %Scale{magnitude: m} = s,
        %Dimension{
          time: 0,
          length: 0,
          mass: 0,
          current: 0,
          temperature: 0,
          substance: 0,
          lintensity: 0
        },
        acc
      ) do
    # convert to readable unit when appropriate -> very special cases
    final_acc = acc |> String.replace_prefix("per_second", "hertz")

    {unit_str, rem_scale} =
      cond do
        m >= 18 -> {"exa" <> final_acc, %{s | magnitude: m - 18}}
        m >= 15 -> {"peta" <> final_acc, %{s | magnitude: m - 15}}
        m >= 12 -> {"tera" <> final_acc, %{s | magnitude: m - 12}}
        m >= 9 -> {"giga" <> final_acc, %{s | magnitude: m - 9}}
        m >= 6 -> {"mega" <> final_acc, %{s | magnitude: m - 6}}
        m >= 3 -> {"kilo" <> final_acc, %{s | magnitude: m - 3}}
        m >= 0 -> {final_acc, s}
        m >= -3 -> {"milli" <> final_acc, %{s | magnitude: m + 3}}
        m >= -6 -> {"micro" <> final_acc, %{s | magnitude: m + 6}}
        m >= -9 -> {"nano" <> final_acc, %{s | magnitude: m + 9}}
        m >= -12 -> {"pico" <> final_acc, %{s | magnitude: m + 12}}
        m >= -15 -> {"femto" <> final_acc, %{s | magnitude: m + 15}}
        true -> {"atto" <> final_acc, %{s | magnitude: m + 18}}
      end

    {String.to_atom(unit_str), rem_scale}
  end

  # REMEMBER to order these by priority when naming a derived unit...
  def to_unit(%Scale{} = scale, %Dimension{length: l} = dim, acc) when l < 0,
    do: to_unit(scale, %{dim | length: -l}, compose_acc_next(acc, "per"))

  def to_unit(%Scale{} = scale, %Dimension{length: l} = dim, acc) when l == 1,
    do: to_unit(scale, %{dim | length: 0}, compose_acc_next(acc, "meter"))

  def to_unit(%Scale{magnitude: m} = scale, %Dimension{length: l} = dim, acc) when l > 0 do
    mag_rem = rem(m, l)
    # move rem to coef
    new_scale = Scale.mag_down(scale, mag_rem)

    mag_div = div(new_scale.magnitude, l)
    # rem is always 0 -> quotient is always integer (no float)

    to_unit(
      %{scale | magnitude: mag_div},
      %{dim | length: 0},
      compose_acc_next(acc, "meter_#{l}")
    )
  end

  def to_unit(%Scale{} = scale, %Dimension{time: t} = dim, acc) when t < 0,
    do: to_unit(scale, %{dim | time: -t}, compose_acc_next(acc, "per"))

  def to_unit(%Scale{} = scale, %Dimension{time: t} = dim, acc) when t == 1,
    do: to_unit(scale, %{dim | time: 0}, compose_acc_next(acc, "second"))

  def to_unit(%Scale{magnitude: m} = scale, %Dimension{time: t} = dim, acc) when t > 0 do
    mag_rem = rem(m, t)
    # move rem to coef
    new_scale = Scale.mag_down(scale, mag_rem)

    mag_div = div(new_scale.magnitude, t)
    # rem is always 0 -> quotient is always integer (no float)

    to_unit(%{scale | magnitude: mag_div}, %{dim | time: 0}, compose_acc_next(acc, "second_#{t}"))
  end

  # TODO : better strategy for this ???
  defp compose_acc_next(acc, next) when acc == "", do: acc <> next

  defp compose_acc_next(acc, next) do
    if not String.ends_with?(acc, "_") do
      acc <> "_" <> next
    else
      acc <> next
    end
  end
end
