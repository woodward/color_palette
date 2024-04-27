# ColorPalette

A library which brings additional named colors [via the 256 ANSI color escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit)
into Elixir (in addition to the 16 standard named `IO.ANSI` colors, such as `:red`, `:blue`, `:cyan`, 
`:light_red`, `:light_blue`, `:light_cyan`, etc.) `ColorPalette` purposely only has minimal dependencies (in
this case, just the `Jason` library).

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
[full list of colors here](https://hexdocs.pm/color_palette/ColorPalette.html#summary).
***IMPORTANT***: note that there are background functions defined for each of the colors (and these are 
not shown in the docs); e.g., for `ColorPalette.aqua/0` there is also `ColorPalette.aqua_background/0`.


### Some of the colors shown in the terminal 

These colors can be seen in a terminal by running 
[this script](https://github.com/woodward/color_palette/blob/main/bin/display_color_palette.exs).

![Colors](https://raw.github.com/woodward/color_palette/master/assets/colors-in-terminal.png)

## Usage

This hex package adds **505** additional named colors to use in Elixir terminal scripts, based on 
the 256 ANSI color code sequences (so some of the color names are duplicates and reference the same color).  
Note that some of the color names are approximations, as the color space for the ANSI color codes is rather 
limited (it's 6 bit (6 x 6 x 6 = 216 colors, plus 40 additional named colors), although there are 9
duplicate hex values so really only 247 unique colors).  The color names were obtained 
by accessing [TheColorAPI](https://www.thecolorapi.com/), [ColorHexa](https://www.colorhexa.com/), 
and also [color-name.com](https://www.color-name.com/).

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
<a href="https://hexdocs.pm/color_palette/ColorPalette.html#alien_armpit/0" style="padding: 0.5rem; color: black; background-color: #87d700;">:alien_armpit</a>
to your scripts!  Or how about some
<a href="https://hexdocs.pm/color_palette/ColorPalette.html#true_blue/0" style="padding: 0.5rem; color: white; background-color: #005fd7;">:true_blue</a>,
or 
<a href="https://hexdocs.pm/color_palette/ColorPalette.html#macaroni_and_cheese/0" style="padding: 0.5rem; color: black; background-color: #ffaf87;">:macaroni_and_cheese</a>
or 
<a href="https://hexdocs.pm/color_palette/ColorPalette.html#bright_turquoise/0" style="padding: 0.5rem; color: black; background-color: #00ffd7;">:bright_turquoise</a>
or 
<a href="https://hexdocs.pm/color_palette/ColorPalette.html#dark_candy_apple_red/0" style="padding: 0.5rem; color: white; background-color: #af0000;">:dark_candy_apple_red</a>
or 
<a href="https://hexdocs.pm/color_palette/ColorPalette.html#laser_lemon/0" style="padding: 0.5rem; color: black; background-color: #ffff5f;">:laser_lemon</a>
or some
<a href="https://hexdocs.pm/color_palette/ColorPalette.html#very_light_malachite_green/0" style="padding: 0.5rem; color: black; background-color: #5fff87;">:very_light_malachite_green</a>

See the main module page for [ColorPalette](https://hexdocs.pm/color_palette/ColorPalette.html) to see a list of all of the colors!

## Data Sources

The 256 IO ANSI color codes are readily available, and a copy of them are stored in JSON format 
[in this file.](https://github.com/woodward/color_palette/blob/main/lib/color_palette/data/ansi_color_codes.json).
These colors were manually grouped by the `ColorPalette` author into 11 color groups 
[in this file](https://github.com/woodward/color_palette/blob/main/lib/color_palette/data/ansi_color_codes_by_group.json) 
(loosely based on the grouping of the [web extended colors from here](https://en.wikipedia.org/wiki/Web_colors#Extended_colors));
note that this was a subjective process. The 16 `IO.ANSI` color names are stored as a 
[a JSON file here.](https://github.com/woodward/color_palette/blob/main/lib/color_palette/data/ansi_color_names.json)
Color names for the 256 ANSI color codes were obtained from [color-name.com](https://www.color-name.com/),  
[thecolorapi.com](https://www.thecolorapi.com/), and [ColorHexa.com](https://www.colorhexa.com/) , and the data are
stored in JSON in this [data directory](https://github.com/woodward/color_palette/blob/main/lib/color_palette/data/).
`Mix.install/2` Elixir scripts to download the data for these sources are found 
[here](https://github.com/woodward/color_palette/blob/main/bin/download_color-name_data.exs), 
[here](https://github.com/woodward/color_palette/blob/main/bin/download_thecolorapi_data.exs), and 
[here](https://github.com/woodward/color_palette/blob/main/bin/download_colorhexa_data.exs), respectively.

## Duplicate ANSI Color Codes

Of the 256 ANSI color codes, surprisingly only 247 are unique hex values (i.e., unique colors); 
there are nine hex codes with duplicate hex values:

|   Hex   |                               Code 1                                  |                                 Code 2                                  | 
|---------|-----------------------------------------------------------------------|-------------------------------------------------------------------------|
| #000000 |   [0](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-0) |   [16](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-16) |
| #0000ff | [12](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-12) |   [21](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-21) |
| #00ff00 | [10](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-10) |   [46](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-46) |
| #00ffff | [14](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-14) |   [51](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-51) |
| #808080 |   [8](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-8) | [244](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-244) |
| #ff0000 |   [9](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-9) | [196](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-196) |
| #ff00ff | [13](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-13) | [201](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-201) |
| #ffff00 | [11](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-11) | [226](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-226) |
| #ffffff | [15](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-15) | [231](https://hexdocs.pm/color_palette/ansi_color_codes.html#color-231) | 