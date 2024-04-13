defmodule ColorPalette.MixProject do
  use Mix.Project

  @source_url "https://github.com/woodward/color_palette"
  @version "0.1.1"

  def project do
    [
      app: :color_palette,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Additional IO.ANSI named colors for Elixir scripts",
      package: package(),

      # Docs
      name: "ColorPalette",
      source_url: "https://github.com/woodward/color_palette",
      docs: [
        main: "ColorPalette",
        extras: ["README.md", "guides/color_table.md", "guides/ansi_color_codes.md", "guides/color_groups.md"]
      ],
      aliases: aliases()
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

  defp aliases do
    [docs: ["generate_guides", "docs"]]
  end

  defp package do
    [
      maintainers: ["Greg Woodward"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: [
        "README.md",
        "lib mix.exs",
        "LICENSE.md",
        "guides/color_table.md",
        "guides/ansi_color_codes.md",
        "guides/color_groups.md"
      ]
    ]
  end
end
