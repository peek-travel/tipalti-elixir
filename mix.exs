defmodule Tipalti.MixProject do
  use Mix.Project

  def project do
    [
      app: :tipalti,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [flags: [:unmatched_returns, :error_handling, :underspecs]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:hackney, "~> 1.11"},
      {:sweet_xml, github: "peek-travel/sweet_xml"},
      {:tesla, "~> 0.10"},
      {:xml_builder, "~> 2.1"}
    ]
  end
end
