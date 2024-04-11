defmodule ColorPalette.ExDocFns do
  @moduledoc false

  def same_as([], _hex, _text_contrast_color), do: ""

  def same_as(same_as, hex, text_contrast_color) do
    links = same_as |> Enum.map(&color_link(&1, hex, text_contrast_color)) |> Enum.join(", ")
    "Same as: " <> links
  end

  def color_link(name, hex, text_contrast_color) do
    """
    <a style="color: #{text_contrast_color}; background-color: ##{hex}; padding-right: 3rem;" href="ColorPalette.html##{name}/0">#{name}</a>
    """
  end
end
