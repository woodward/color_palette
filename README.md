# ColorPalette

A library which brings additional named colors into Elixir (in addition to the standard
`IO.ANSI` colors.

## Installation

The package can be installed by adding `color_palette` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:color_palette, "~> 0.1"}
  ]
end
```

Documentation can be found [here](https://hexdocs.pm/color_palette/readme.html) and a 
[full list of colors here](ColorPalette.html#summary).

## Usage

This hex package adds some ~364 additional named colors to use in Elixir terminal scripts, based on 
the 256 ANSI color code sequences (so some of the color names are duplicates and reference the same color).  
These are in addition to the 16 named colors in `IO.ANSI` (e.g., `:black`, `:red`, `:light_cyan`, etc.) 
Note that some of the colors are approximations, as the color space for the ANSI color codes is rather 
limited.  The values were obtained by accessing [TheColorAPI](https://www.thecolorapi.com/) and 
also [color-name.com](https://www.color-name.com/).

Usage is similar to `IO.ANSI`.  So in your Elixir script module, you can either reference ColorPalette
color functions directly (e.g., `ColorPalette.aero_blue/0`) or you can import all of the color functions
for easier usage:

```elixir

def MyModule do
  import ColorPalette

  def fancy_print do
    IO.puts(aero_blue() <> "This line is in aero blue!" <> reset())
    IO.puts(alien_armpit() <> "This line is in alien armpit!" <> reset())
  end
end

MyModule.fancy_print()
```

So add some [:alien_armpit](ColorPalette.html#alien_armpit/0) to your scripts!  Or how about some
[:caribbean_green_pearl](ColorPalette.html#caribbean_green_pearl/0), or [:macaroni_and_cheese](ColorPalette.html#macaroni_and_cheese/0), 
or some [:very_light_malachite_green](ColorPalette.html#very_light_malachite_green/0).

See the main module page for `ColorPalette` to see a list of all of the colors!