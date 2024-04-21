defmodule ColorPalette.ColorGroup do
  @moduledoc """
  Represents one of the 11 color groups in the [web extended colors](https://en.wikipedia.org/wiki/Web_colors#Extended_colors)

  See [this guide](color_groups.html) for a visual depiction of the 11 color groups and their
  constituent ANSI color codes.

  Note that the grouping into color groups is somewhat arbitrary and definitely non-definitive.
  """

  @type t ::
          :blue
          | :brown
          | :cyan
          | :gray_and_black
          | :green
          | :orange
          | :pink
          | :purple_violet_and_magenta
          | :red
          | :white
          | :yellow

  @color_groups [
    :blue,
    :brown,
    :cyan,
    :gray_and_black,
    :green,
    :orange,
    :pink,
    :purple_violet_and_magenta,
    :red,
    :white,
    :yellow
  ]

  @doc """
  Returns the 11 color groups based on the [web extended colors](https://en.wikipedia.org/wiki/Web_colors#Extended_colors)
  """
  @spec color_groups() :: [__MODULE__.t()]
  def color_groups, do: @color_groups
end
