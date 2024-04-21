defmodule ColorPalette do
  @moduledoc """
  ## Color Palette Functions
  - `colors/0`: A map between the color name (e.g., `:black`) and the `ColorPalette.Color` struct.
  - `ansi_color_codes/0` - A list of all 256 ANSI color codes
  - `color_groups_to_ansi_color_codes/0` - A map between the color group and the ANSI color codes
  - `color_groups/0` - 11 color groups based on the [web extended colors](https://en.wikipedia.org/wiki/Web_colors#Extended_colors)
  - `io_ansi_color_names/0` - The `IO.ANSI` colors and their corresponding text contrast colors.
  - `reset/0` - Delegates to the `IO.ANSI.reset/0` function.
  - `find_by_hex/1` - Finds a color by its hex value.
  - `find_by_code/1` - Finds a color by its ANSI code number (e.g., 0..255).

  ## Colors

  See below for the color descriptions.  ***IMPORTANT*** Note that there are **background versions** for
  each color; e.g., the function `tea_green_background/0` (which is not listed below) is the
  background color for
  <a href="ColorPalette.html#tea_green/0" style="padding: 0.5rem; color: black; background-color: #d7ffaf;">tea_green/0</a>

  """

  defdelegate reset(), to: IO.ANSI

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color
  alias ColorPalette.DataConverter

  @before_compile ColorPalette.PrecompileHook

  @spec ansi_color_codes_to_color_names() :: %{ANSIColorCode.t() => [Color.t()]}
  def ansi_color_codes_to_color_names do
    DataConverter.ansi_color_codes_to_color_names(ansi_color_codes(), colors())
  end

  @spec find_by_hex(ANSIColorCode.hex()) :: [Color.t()]
  def find_by_hex(hex), do: colors() |> DataConverter.find_by_hex(hex)

  @spec find_by_code(ANSIColorCode.code()) :: [Color.t()]
  def find_by_code(code), do: colors() |> DataConverter.find_by_code(code)

  @spec find_by_source(Color.source()) :: [Color.t()]
  def find_by_source(source) do
    colors()
    |> Enum.filter(fn {_name, color} ->
      source in color.source
    end)
  end
end
