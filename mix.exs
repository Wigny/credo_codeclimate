defmodule CredoCodeClimate.MixProject do
  use Mix.Project

  def project do
    [
      app: :credo_codeclimate,
      version: "0.1.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, ">= 1.7.0"}
    ]
  end
end
