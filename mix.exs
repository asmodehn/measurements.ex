defmodule Measurements.MixProject do
  use Mix.Project

  def project do
    [
      app: :measurements,
      version: "0.1.3",
      elixir: "~> 1.14",
      # Useful for a lib ? or useless and confusing ?
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),

      # Docs
      name: "Measurements",
      source_url: "https://github.com/asmodehn/measurements.ex",
      # homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      docs: [
        # The main page in the docs
        main: "readme",
        # logo: "path/to/logo.png",
        extras: ["README.md", "DEMO.livemd"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Measurements helps to manage values with errors, representing physical quantities.
    The package provides error propagation during calculations, as well as some automatic unit conversion."
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* DEMO* LICENSE*),
      licenses: ["GPL-3.0-or-later"],
      links: %{"GitHub" => "https://github.com/asmodehn/measurements.ex"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:type_class, "~> 1.2"},
      # {:type_class, path: "/home/alexv/Projects/elixir-playground/type_class", override: true},
      {:type_class, github: "asmodehn/type_class", branch: "test_macro", override: true},
      # {:witchcraft, "~> 1.0"},
      # {:witchcraft, path: "/home/alexv/Projects/elixir-playground/witchcraft", override: true},
      {:stream_data, "~> 0.5", only: :test},
      {:nimble_parsec, "~> 1.0"},

      # For tests
      {:hammox, "~> 0.7", only: :test},

      # For development only
      {:committee, "~> 1.0.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
