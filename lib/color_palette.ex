defmodule ColorPalette do
  @moduledoc """
  ## Color Palette Functions
  - `colors/0`: The Colors
  - `ansi_color_codes/0`: The ANSI color codes

  ## Group 2: Colors

  See below

  """

  defdelegate reset(), to: IO.ANSI

  @before_compile ColorPalette.PrecompileHook
end
