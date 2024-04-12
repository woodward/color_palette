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

  See below for the color descriptions.  ***IMPORTANT*** Note that there are background versions for
  each color; e.g., the function `tea_green_background/0` (which is not listed below) is the
  background color for `tea_green/0`.

  """

  defdelegate reset(), to: IO.ANSI

  @before_compile ColorPalette.PrecompileHook
end
