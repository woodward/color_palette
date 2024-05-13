defmodule ColorPalette.MixProject do
  use Mix.Project

  @source_url "https://github.com/woodward/color_palette"
  @version "0.1.9"

  def project do
    [
      app: :color_palette,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Additional IO.ANSI named colors for Elixir scripts",
      package: package(),
      dialyzer: [plt_add_apps: [:mix]],

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
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4", only: [:test, :prod, :dev], runtime: runtime?()},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [docs: ["generate_guides", "docs"]]
  end

  defp runtime?() do
    # This makes this runtime flag be determined at runtime rather than at compile time.
    # I.e., I wanted to specify the following in deps() but it is not possible:
    #
    # {:jason, "~> 1.4", only: [:test, :dev], runtime: true, only: :prod, runtime: false},
    Mix.env() == :test || Mix.env() == :dev
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
        "lib",
        "mix.exs",
        "LICENSE.md",
        "guides/color_table.md",
        "guides/ansi_color_codes.md",
        "guides/color_groups.md"
      ]
    ]
  end
end
