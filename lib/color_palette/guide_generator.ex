defmodule ColorPalette.GuideGenerator do
  @moduledoc """
  Generates the guides for the ExDocs
  """

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color
  alias ColorPalette.ColorGroup

  @doc """
  Generates the [color groups guide](color_groups.html) by writing a markdown file
  `color_groups.md` into the `guides` directory
  """
  @spec generate_color_groups_guide :: :ok
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
      |> Enum.sort_by(fn {color_group, _} -> color_group end)
      |> Enum.reduce(content, fn {color_group, ansi_color_codes}, acc ->
        acc = acc <> color_group_name(color_group, length(ansi_color_codes))

        ansi_color_codes
        |> Enum.sort_by(& &1.code)
        |> Enum.reduce(acc, fn ansi_color_code, acc ->
          color_names = Map.get(ansi_color_codes_to_color_names, ansi_color_code)
          first_color_name = color_names |> List.first()
          color = Map.get(colors, first_color_name)
          text_contrast_color = color.text_contrast_color
          hex = ansi_color_code.hex
          code = ansi_color_code.code

          acc <> color_block(code, hex, text_contrast_color, color_names, nil, "padding: 0.5rem;")
        end)
      end)

    File.write!("guides/color_groups.md", content)
    :ok
  end

  @doc """
  Generates the [ANSI Color Codes list](ansi_color_codes.html) by writing a markdown file
  `ansi_color_codes.md` into the `guides` directory
  """
  @spec generate_ansi_color_codes_guide :: :ok
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
        color_group = ansi_color_code.color_group

        acc <> color_block(code, hex, text_contrast_color, color_names, color_group, "padding: 1rem; margin-bottom: 1rem")
      end)

    File.write!("guides/ansi_color_codes.md", content)
    :ok
  end

  @spec color_block(
          ANSIColorCode.code(),
          ANSIColorCode.hex(),
          Color.text_contrast_color(),
          [Color.color_name()],
          ColorGroup.t() | nil,
          String.t()
        ) ::
          String.t()
  defp color_block(code, hex, text_contrast_color, color_names, color_group, div_styling) do
    color_names_label = if length(color_names) == 1, do: "Color Name", else: "Color Names"

    color_group_link =
      if color_group, do: ColorPalette.ExDocUtils.color_group_link(hex, text_contrast_color, color_group), else: nil

    """
    <div style="color: #{text_contrast_color}; background-color: ##{hex}; #{div_styling}" id="color-#{code}">
      <span style="margin-right: 2rem; font-weight: bold;">#{code}:</span>
      <span style="margin-right: 2rem;">Hex: ##{hex} </span>
      <span>
        <span style="margin-right: 1rem;">#{color_names_label}: </span>
        <span style="margin-right: 1rem;">
          #{color_links(color_names, hex, text_contrast_color)}
        </span>
        #{color_group_link}
      </span>
    </div>\n\n
    """
  end

  @spec color_links([Color.color_name()], ANSIColorCode.hex(), Color.text_contrast_color()) :: String.t()
  defp color_links(color_names, hex, text_contrast_color) do
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

  @spec color_group_name(ColorGroup.t() | nil, integer()) :: String.t()
  defp color_group_name(nil, count), do: "## Uncategorized (#{count} colors)\n\n"

  defp color_group_name(name, count) do
    names =
      name
      |> Atom.to_string()
      |> String.split("_")
      |> Enum.map(&String.capitalize(&1))
      |> Enum.join(", ")
      |> String.replace(", And, ", " and ")

    """
    <div style="margin-top: 5rem;" id=#{name} />
    ## #{names} (#{count} colors)\n\n
    """
  end
end
