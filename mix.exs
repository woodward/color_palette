defmodule ColorPalette.MixProject do
  use Mix.Project

  @source_url "https://github.com/woodward/color_palette"
  @version "0.1.0"

  def project do
    [
      app: :color_palette,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      licenses: "LICENSE.txt",
      description: "A color library for Elixir scripts",
      package: package(),
      links: [""],

      # Docs
      name: "ColorPalette",
      source_url: "https://github.com/woodward/color_palette",
      docs: [
        main: "ColorPalette",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Greg Woodward"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
  end
end
