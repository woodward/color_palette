defmodule ColorPalette do
  @moduledoc """
  ## Color Palette Functions
  - `colors/0`: A map between the color name (e.g., `:black`) and the `ColorPalette.Color` struct.
  - `ansi_color_codes/0` - A list of all 256 ANSI color codes
  - `color_groups_to_ansi_color_codes/0` - A map between the color group and the ANSI color codes
  - `color_groups/0` - 11 color groups based on the [web extended colors](https://en.wikipedia.org/wiki/Web_colors#Extended_colors)
  - `io_ansi_colors/0` - The `IO.ANSI` colors and their corresponding text contrast colors.
  - `reset/0` - Delegates to the `IO.ANSI.reset/0` function.

  ## Colors

  See below for the color descriptions.  ***IMPORTANT*** Note that there are **background versions** for
  each color; e.g., the function `tea_green_background/0` (which is not listed below) is the
  background color for
  <a href="ColorPalette.html#tea_green/0" style="padding: 0.5rem; color: black; background-color: #d7ffaf;">tea_green/0</a>

  """

  defdelegate reset(), to: IO.ANSI

  @before_compile ColorPalette.PrecompileHook

  def unnamed_ansi_color_codes do
    ColorPalette.DataConverter.unnamed_ansi_color_codes(ansi_color_codes(), colors())
  end
end
