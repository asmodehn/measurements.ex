# Measurements


[![Build Status](https://github.com/asmodehn/measurements.ex/workflows/elixir/badge.svg?branch=main)](https://github.com/asmodehn/measurements.ex/actions) [![Hex pm](https://img.shields.io/hexpm/v/measurements.svg?style=flat)](https://hex.pm/packages/measurements) [![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/measurements/)

Measurements is a library for computation of **physical quantities** (time, distances, etc.) in Elixir.

A quantity is represented by **a struct with a value, a unit and a positive error**.

Error is propagated through calculations, and unit prevent collision of unrelated quantities.
Automatic conversion of unit (in scale) is supported.

Conversion of unit, across dimension, could ultimately be supported.
But is a very large endaevour and the package API is not stable enough just yet.

See https://en.wikipedia.org/wiki/Dimensional_analysis as reference.

Dimensions supported:
- [X] Time (T)
- [X] Length (L)
- [ ] Mass (M)
- [ ] Electric Current (I)
- [ ] Absolute Temperature (Θ)
- [ ] Amount of Substance (N)
- [ ] Luminous Intensity (J)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `measurements` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:measurements, "~> 0.1.2"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/measurements>.


## Testing in Iex

```
$ mix test --trace
```

Or for a more interactive approach:

```
$ iex -S mix
```

## Testing in Livebook

[Install livebook as an escript](https://github.com/livebook-dev/livebook#escript) and start it:

```
livebook server
```

From there you can open DEMO.livemd to see `measurements` in action, and try it for yourself !


## How to develop

Optionally, setup [direnv](https://direnv.net/) with [asdf](https://github.com/asdf-vm/asdf). 
This will allow to work with another elixir version than your system's one.

Then:
- [install it](#installation)
- [run the tests](#testing-in-iex)
- [check the livebook](#testing-in-livebook)
- [browse the docs](https://hexdocs.pm/measurements)
- [have a look at the code](https://github.com/asmodehn/measurements.ex)

Want to change something ?
  - [open an issue to discuss](https://github.com/asmodehn/measurements.ex/issues)
  - Make it work
  - [open a PR to show off the work](https://github.com/asmodehn/measurements.ex/pulls)
  - Make it beautiful
  - Let's merge it! 
  - Make it fast