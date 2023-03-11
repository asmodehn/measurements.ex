defmodule Measurements.Unit.Parser.TMPAPI do
  # Internal API
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
    case str do
      "second" -> Time
      "hertz" -> Time
      "meter" -> Length
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
    choice([string("second"), string("hertz"), string("meter")])
    |> map({TMPAPI, :unit, []})
    |> label("core unit among these: second, hertz, meter")

  maybe_neg_integer =
    choice([
      ascii_char([?-]),
      optional(ascii_char([?+]))
    ])
    |> ascii_char([?0..?9])
    |> reduce({TMPAPI, :exponent, []})

  exponent =
    choice([
      ignore(string("_")) |> concat(maybe_neg_integer),
      # default to dimension one (integer), since unit is present !
      string("") |> replace(1)
    ])
    |> label("exponent integer, positive or negative, separated by a leading '_' ")

  defparsec(
    :unit,
    repeat(
      scale_prefix
      |> concat(core_unit)
      |> concat(exponent)
      |> ignore(optional(string("_")))
    )
  )
end
