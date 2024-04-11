defmodule ColorPalette do
  @moduledoc """
  ## Color Palette Functions
  - `colors/0`: The Colors
  - `ansi_color_codes/0`: The ANSI color codes

  ## Group 2: Colors

  See below for the color descriptions.  Note that there are background versions of each color;
  e.g., `tea_green_background/0` is the background color for `tea_green/0`.

  """

  defdelegate reset(), to: IO.ANSI

  @before_compile ColorPalette.PrecompileHook
end
