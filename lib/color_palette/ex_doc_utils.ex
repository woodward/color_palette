defmodule ColorPalette.ExDocUtils do
  @moduledoc """
  Utility functions for building the ExDocs
  """

  def same_as([], _hex, _text_contrast_color), do: ""

  def same_as(same_as, hex, text_contrast_color) do
    links = same_as |> Enum.map(&color_link(&1, hex, text_contrast_color)) |> Enum.join(", ")

    """
    <span style="padding-right: 2rem;">
      Same as: #{links}
    </span>
    """
  end

  def color_link(name, hex, text_contrast_color) do
    """
    <a style="color: #{text_contrast_color}; background-color: ##{hex};" href="ColorPalette.html##{name}/0">#{name}</a>
    """
  end

  def source_link(source, text_contrast_color, hex) do
    url = ColorPalette.DataURLs.url(source, hex: hex)

    """
    <a style="color: #{text_contrast_color}; background-color: ##{hex}; padding-right: 2rem;" href="#{url}">Source: #{source_name(source)}</a>
    """
  end

  def color_group_link(hex, text_contrast_color, color_group) do
    url = "color_groups.html##{color_group}"

    """
    <a style="color: #{text_contrast_color}; background-color: ##{hex}; padding-right: 2rem;" href="#{url}">Color Group: #{color_group}</a>
    """
  end

  def source_name(:color_name_dot_com), do: "color-name.com"
  def source_name(:color_data_api), do: "The Color API"
end
