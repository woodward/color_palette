# ColorPalette

A library which brings additional named colors into Elixir (in addition to the 16 standard named
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

So add some 
<a href="ColorPalette.html#alien_armpit/0" style="padding: 0.5rem; color: black; background-color: #87d700;">:alien_armpit</a>
to your scripts!  Or how about some
<a href="ColorPalette.html#true_blue/0" style="padding: 0.5rem; color: white; background-color: #005fd7;">:true_blue</a>,
or 
<a href="ColorPalette.html#macaroni_and_cheese/0" style="padding: 0.5rem; color: black; background-color: #ffaf87;">:macaroni_and_cheese</a>
or 
<a href="ColorPalette.html#bright_turquoise/0" style="padding: 0.5rem; color: black; background-color: #00ffd7;">:bright_turquoise</a>
or 
<a href="ColorPalette.html#dark_candy_apple_red/0" style="padding: 0.5rem; color: white; background-color: #af0000;">:dark_candy_apple_red</a>
or 
<a href="ColorPalette.html#laser_lemon/0" style="padding: 0.5rem; color: black; background-color: #ffff5f;">:laser_lemon</a>
or some
<a href="ColorPalette.html#very_light_malachite_green/0" style="padding: 0.5rem; color: black; background-color: #5fff87;">:very_light_malachite_green</a>

See the main module page for `ColorPalette` to see a list of all of the colors!
