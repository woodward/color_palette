defmodule ColorPalette do
  @moduledoc """
  ## Color Palette Functions
  - `colors/0`: A map between the color name (e.g., `:black`) and the `ColorPalette.Color` struct.
  - `ansi_color_codes/0` - A list of all 256 ANSI color codes
  - `color_groups_to_ansi_color_codes/0` - A map between the color group and the ANSI color codes
  - `io_ansi_color_names/0` - The `IO.ANSI` colors and their corresponding text contrast colors.
  - `reset/0` - Delegates to the `IO.ANSI.reset/0` function.
  - `ansi_color_codes_to_color_names/0` - A mapping between `ColorPalette.ANSIColorCode` and color names
  - `find_by_hex/1` - Finds a color by its hex value.
  - `find_by_code/1` - Finds a color by its ANSI code number (e.g., 0..255).
  - `color_names/0` - Returns the list of all color names (e.g., `[:aero_blue, :alien_armpit, :alto, ...]`)
  - `random_color_name/0` - Returns a random color name
  - `print_using_random_color/2` - Prints a message in a random color

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

  @doc """
  A mapping between the ANSI color codes (e.g, `ColorPalette.ANSIColorCode`) and color
  names (e.g., `ColorPalette.Color.name()`)
  """
  @spec ansi_color_codes_to_color_names() :: %{ANSIColorCode.t() => [Color.t()]}
  def ansi_color_codes_to_color_names do
    DataConverter.ansi_color_codes_to_color_names(ansi_color_codes(), hex_to_color_names())
  end

  @doc """
  Finds the colors with a certain hex value, e.g., "aabb00"
  """
  @spec find_by_hex(ANSIColorCode.hex()) :: [Color.t()]
  def find_by_hex(hex), do: colors() |> DataConverter.find_by_hex(hex)

  @doc """
  Finds the colors with a certain ANSI color code
  """
  @spec find_by_code(ANSIColorCode.code()) :: [Color.t()]
  def find_by_code(code), do: colors() |> DataConverter.find_by_code(code)

  @doc """
  Finds the colors that were obtained from `source`, where `source` is one of `ColorPalette.source()`
  """
  @spec find_by_source(Color.source()) :: [Color.t()]
  def find_by_source(source) do
    colors()
    |> Enum.filter(fn {_name, color} ->
      source in color.source
    end)
  end

  @doc """
  Returns the list of all color names
  """
  @spec color_names() :: [Color.name()]
  def color_names, do: colors() |> Map.keys() |> Enum.sort()

  @doc """
  Returns a random color name
  """
  @spec random_color_name() :: Color.name()
  def random_color_name, do: color_names() |> Enum.random()

  @doc """
  Prints a message in a random color
  """
  @spec print_using_random_color(String.t(), Keyword.t()) :: Color.name()
  def print_using_random_color(message, opts \\ []) do
    show_color_name? = Keyword.get(opts, :show_color_name?, false)
    random_color = random_color_name()
    message = if show_color_name?, do: "#{random_color}:  #{message}", else: message
    IO.puts(apply(ColorPalette, random_color, []) <> message <> reset())
    random_color
  end
end
