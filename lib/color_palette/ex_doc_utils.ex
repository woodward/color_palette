defmodule ColorPalette.ExDocUtils do
  @moduledoc """
  Utility functions for building the ExDocs
  """

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color
  alias ColorPalette.ColorGroup
  alias ColorPalette.DataURLs

  @spec same_as([Color.color_name()], ANSIColorCode.hex(), Color.text_contrast_color()) :: String.t()
  def same_as([], _hex, _text_contrast_color), do: ""

  def same_as(same_as, hex, text_contrast_color) do
    links = same_as |> Enum.map(&color_link(&1, hex, text_contrast_color)) |> Enum.join(", ")

    """
    <span style="padding-right: 2rem;">
      Same as: #{links}
    </span>
    """
  end

  @spec color_link(Color.color_name(), ANSIColorCode.hex(), Color.text_contrast_color()) :: String.t()
  def color_link(name, hex, text_contrast_color) do
    """
    <a style="color: #{text_contrast_color}; background-color: ##{hex};" href="ColorPalette.html##{name}/0">#{name}</a>
    """
  end

  @spec source_links([Color.source()], Color.text_contrast_color(), ANSIColorCode.hex(), Color.color_name()) :: String.t()
  def source_links(sources, text_contrast_color, hex, name) do
    source_span = """
    <span style="margin-right: 2rem;"> Source: </span>
    """

    sources
    |> Enum.reduce(source_span, fn source, acc ->
      acc <> source_link(source, text_contrast_color, hex, name)
    end)
  end

  @spec source_link(Color.source(), Color.text_contrast_color(), ANSIColorCode.hex(), Color.color_name()) :: String.t()
  def source_link(source, text_contrast_color, hex, name) do
    url = DataURLs.url(source, hex: hex, name: name)

    """
    <a style="color: #{text_contrast_color}; background-color: ##{hex}; padding-right: 2rem;" href="#{url}">#{source_name(source)}</a>
    """
  end

  @spec color_group_link(ANSIColorCode.hex(), Color.text_contrast_color(), ColorGroup.t()) :: String.t()
  def color_group_link(hex, text_contrast_color, color_group) do
    url = "color_groups.html##{color_group}"

    """
    <a style="color: #{text_contrast_color}; background-color: ##{hex}; padding-right: 2rem;" href="#{url}">Color Group: #{color_group}</a>
    """
  end

  @spec source_name(Color.source()) :: String.t()
  def source_name(:color_name_dot_com), do: "color-name.com"
  def source_name(:io_ansi), do: "IO.ANSI"
  def source_name(:color_data_api), do: "The Color API"
  def source_name(:colorhexa), do: "ColorHexa"
end
