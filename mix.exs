defmodule Measurements.MixProject do
  use Mix.Project

  def project do
    [
      app: :measurements,
      version: "0.1.2",
      elixir: "~> 1.14",
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
        main: "Measurements",
        # logo: "path/to/logo.png",
        # TODO: , "DEMO.livemd"]
        extras: ["README.md"]
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
      files: ~w(lib .formatter.exs mix.exs README* ../LICENSE*),
      licenses: ["GPL-3.0-or-later"],
      links: %{"GitHub" => "https://github.com/asmodehn/measurements.ex"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
