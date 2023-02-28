# Measurements

Measurements is a library for computation of physical quantities (time, distances, etc.) in Elixir
A quantity is represented by a struct with a value, a unit and an error.

Error is propagated through calculations, and unit prevent collision of unrelated quantities.
Automatic conversion of unit is supported.

See https://en.wikipedia.org/wiki/Dimensional_analysis as reference.

Dimensions supported:
- [X] Time (T)
- [ ] Length (L)
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
    {:measurements, "~> 0.1.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/measurements>.

