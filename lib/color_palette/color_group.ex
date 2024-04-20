defmodule ColorPalette.ColorGroup do
  @moduledoc """
  Represents one of the 11 color groups in the [web extended colors](https://en.wikipedia.org/wiki/Web_colors#Extended_colors)
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

  def color_groups, do: @color_groups
end
