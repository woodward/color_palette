defmodule ColorPalette.GuideGenerator do
  @moduledoc """
  Generates the guides for the ExDocs
  """

  def generate_color_groups_guide do
    content = """
    # Color Groups

    Based on the [web extended colors](https://en.wikipedia.org/wiki/Web_colors#Extended_colors)
    although the colors were grouped by hand by the `ColorPalette` author.

    """

    color_groups = ColorPalette.color_groups_to_ansi_color_codes()
    colors = ColorPalette.colors()
    ansi_color_codes_to_color_names = ColorPalette.ansi_color_codes_to_color_names()

    content =
      color_groups
      |> Enum.reduce(content, fn {color_group, ansi_color_codes}, acc ->
        acc = acc <> color_group_name(color_group)

        ansi_color_codes
        |> Enum.sort_by(& &1.code)
        |> Enum.reduce(acc, fn ansi_color_code, acc ->
          color_names = Map.get(ansi_color_codes_to_color_names, ansi_color_code)
          first_color_name = color_names |> List.first()
          color = Map.get(colors, first_color_name)
          text_contrast_color = color.text_contrast_color
          hex = ansi_color_code.hex
          code = ansi_color_code.code

          acc <> color_block(code, hex, text_contrast_color, color_names, "padding: 0.5rem;")
        end)
      end)

    File.write!("guides/color_groups.md", content)
    :ok
  end

  def generate_ansi_color_codes_guide do
    content = """
    # 256 ANSI Color Codes

    See the [ANSI 8-bit color codes](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit)
    and also the `IO.ANSI` module.

    """

    ansi_color_codes = ColorPalette.ansi_color_codes_to_color_names()
    colors = ColorPalette.colors()

    content =
      ansi_color_codes
      |> Enum.sort_by(fn {ansi_color_code, _} -> ansi_color_code.code end)
      # |> Enum.take(50)
      |> Enum.reduce(content, fn {ansi_color_code, color_names}, acc ->
        first_color_name = color_names |> List.first()
        color = Map.get(colors, first_color_name)
        text_contrast_color = color.text_contrast_color
        hex = ansi_color_code.hex
        code = ansi_color_code.code

        acc <> color_block(code, hex, text_contrast_color, color_names, "padding: 1rem; margin-bottom: 1rem")
      end)

    File.write!("guides/ansi_color_codes.md", content)
    :ok
  end

  def color_block(code, hex, text_contrast_color, color_names, div_styling) do
    """
    <div style="color: #{text_contrast_color}; background-color: ##{hex}; #{div_styling}">
      <span style="margin-right: 2rem; font-weight: bold;">#{code}:</span>
      <span style="margin-right: 2rem;">Hex: ##{hex} </span>
      <span>
        <span style="margin-right: 1rem;">Color Names: </span>
        #{color_links(color_names, hex, text_contrast_color)}
      </span>
    </div>\n\n
    """
  end

  def color_links(color_names, hex, text_contrast_color) do
    color_names
    |> Enum.map(fn color_name ->
      """
      <a style="color: #{text_contrast_color}; background_color: ##{hex}" href="ColorPalette.html##{color_name}/0">
        :#{color_name}
      </a>
      """
    end)
    |> Enum.join(", ")
  end

  def color_group_name(nil), do: "## Uncategorized\n\n"

  def color_group_name(name) do
    names =
      name
      |> Atom.to_string()
      |> String.split("_")
      |> Enum.map(&String.capitalize(&1))
      |> Enum.join(" ")

    "## #{names}\n\n"
  end
end
