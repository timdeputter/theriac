defmodule Theriac.Mixfile do
  use Mix.Project

  def project do
    [app: :theriac,
     version: "0.0.1",
     description: "Implementation of clojure style transducers in elixir",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps,
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:excoveralls, "~> 0.3", only: [:dev, :test]}]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Tim de Putter"],
     licenses: ["The MIT License"],
     links: %{"GitHub" => "https://github.com/timdeputter/theriac"}]
  end

end
