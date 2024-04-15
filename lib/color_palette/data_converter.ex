defmodule ColorPalette.DataConverter do
  @moduledoc false

  alias ColorPalette.Color

  def new_convert_color_data_api_raw_data(color_data, ansi_color_codes) do
    Enum.zip(color_data, ansi_color_codes)
    |> Enum.map(fn {raw_color, ansi_color_code} ->
      name = raw_color.name.value |> new_color_name_to_atom()
      names = if is_list(name), do: name, else: [name]

      colors =
        names
        |> Enum.map(fn color_name ->
          distance_to_closest_named_hex = raw_color.name.distance
          exact_name_match? = raw_color.name.exact_match_name
          closest_named_hex = raw_color.name.closest_named_hex |> String.replace("#", "")

          %Color{
            name: color_name,
            ansi_color_code: ansi_color_code,
            text_contrast_color: text_contrast_color(raw_color),
            source: [:color_data_api],
            distance_to_closest_named_hex: distance_to_closest_named_hex,
            exact_name_match?: exact_name_match?,
            closest_named_hex: closest_named_hex
          }
        end)

      if length(colors) == 1, do: List.first(colors), else: colors
    end)
  end

  def color_groups_to_ansi_color_codes(ansi_color_codes, color_groups) do
    color_groups_to_ansi_color_codes =
      color_groups
      |> Enum.reduce(%{}, fn color_group, acc ->
        Map.put(acc, color_group, [])
      end)

    ansi_color_codes
    |> Enum.reduce(color_groups_to_ansi_color_codes, fn ansi_color_code, acc ->
      color_group = ansi_color_code.color_group
      Map.update(acc, color_group, [ansi_color_code], fn value -> [ansi_color_code] ++ value end)
    end)
  end

  def new_color_name_to_atom(name) do
    names =
      name
      |> String.downcase()
      |> String.replace(~r/\(.*\)/, "")
      |> String.replace(~r/é/, "")
      |> String.split("/")
      |> Enum.map(&String.trim(&1))
      |> Enum.map(&String.replace(&1, " ", "_"))
      |> Enum.map(&String.replace(&1, "'", ""))
      |> Enum.map(&String.replace(&1, "-", "_"))
      |> Enum.map(&String.to_atom(&1))

    if length(names) == 1, do: List.first(names), else: names
  end

  def text_contrast_color(color) do
    case color.contrast.value do
      "#ffffff" -> :white
      "#000000" -> :black
      _ -> raise "Unexpected doc text color"
    end
  end

  def group_colors_by_name(colors) do
    colors
    |> Enum.map(fn colors_for_code ->
      colors_for_code = colors_for_code |> List.flatten()

      names_for_this_code = colors_for_code |> Enum.map(& &1.name)

      colors_for_code
      |> Enum.group_by(& &1.name)
      |> Enum.map(fn {_color_name, colors_for_this_name} ->
        [first_color | rest] = colors_for_this_name

        rest
        |> Enum.reduce(first_color, fn next_color, acc ->
          %{acc | source: acc.source ++ next_color.source}
        end)
      end)
      |> Enum.map(fn color ->
        %{color | same_as: names_for_this_code |> Enum.reject(&(&1 == color.name))}
      end)
    end)
  end

  def new_convert_color_name_dot_com_raw_data(color_name_dot_com_raw_data, ansi_color_codes) do
    Enum.zip(color_name_dot_com_raw_data, ansi_color_codes)
    |> Enum.map(fn {raw_color, ansi_color_code} ->
      color_name = raw_color.name |> new_color_name_to_atom()

      %Color{
        name: color_name,
        ansi_color_code: ansi_color_code,
        text_contrast_color: String.to_atom(raw_color.text_contrast_color),
        source: [:color_name_dot_com],
        exact_name_match?: false,
        distance_to_closest_named_hex: nil,
        closest_named_hex: nil
      }
    end)
  end

  def color_names_to_colors(colors) do
    colors
    |> Enum.reduce(%{}, fn color, acc ->
      if is_list(color) do
        color
        |> Enum.reduce(acc, fn individual_color, acc ->
          Map.update(acc, individual_color.name, [individual_color], fn value -> [individual_color] ++ value end)
        end)
      else
        Map.update(acc, color.name, [color], fn value -> [color] ++ value end)
      end
    end)
  end

  def new_convert_ansi_colors_to_color_names(ansi_colors, ansi_color_codes) do
    Enum.zip(ansi_colors, ansi_color_codes)
    |> Enum.map(fn {ansi_color, ansi_color_code} ->
      %Color{
        name: ansi_color.name,
        text_contrast_color: ansi_color.text_contrast_color,
        ansi_color_code: ansi_color_code,
        source: [:io_ansi],
        closest_named_hex: nil,
        exact_name_match?: true,
        distance_to_closest_named_hex: 0
      }
    end)
  end

  def combine_colors(io_ansi_colors, color_data_api_colors, color_name_dot_com_colors) do
    # Should be 256 - 16:
    required_padding = length(color_data_api_colors) - length(io_ansi_colors)

    nil_padding = 0..required_padding |> Enum.reduce([], fn _index, acc -> [nil] ++ acc end)
    io_ansi_colors_padded_with_nils = io_ansi_colors ++ nil_padding

    Enum.zip(io_ansi_colors_padded_with_nils, color_data_api_colors)
    |> Enum.zip(color_name_dot_com_colors)
    |> Enum.map(fn {{io_ansi, color_data_api}, color_name_dot_com} ->
      [io_ansi, color_data_api, color_name_dot_com]
    end)
    |> Enum.map(fn colors_for_code ->
      colors_for_code |> Enum.reject(&(&1 == nil))
    end)
  end

  def ansi_color_codes_to_color_names(ansi_color_codes, colors) do
    ansi_color_codes_to_color_names =
      ansi_color_codes
      |> Enum.reduce(%{}, fn ansi_color_code, acc ->
        Map.put(acc, ansi_color_code, [])
      end)

    colors
    |> Enum.reduce(ansi_color_codes_to_color_names, fn {color_name, color_data}, acc ->
      ansi_color_code = color_data.ansi_color_code
      Map.update(acc, ansi_color_code, [color_name], fn value -> [color_name] ++ value end)
    end)
  end

  def find_by_hex(color_names, hex) do
    hex = hex |> String.replace("#", "")

    case color_names |> Enum.find(fn {_color_name, color} -> color.ansi_color_code.hex == hex end) do
      nil -> {:error, "Hex value ##{hex} not found"}
      result -> result |> elem(1)
    end
  end

  def find_by_code(_color_names, code) when code < 0 or code > 255 do
    {:error, "Code #{code} is not valid"}
  end

  def find_by_code(color_names, code) do
    color_names
    |> Enum.find(fn {_color_name, color} -> color.ansi_color_code.code == code end)
    |> elem(1)
  end

  def unnamed_ansi_color_codes(color_map) do
    ansi_color_code_set = 0..255 |> Range.to_list() |> MapSet.new()

    color_set =
      color_map
      |> Enum.reduce(MapSet.new(), fn {_color_name, color}, acc ->
        MapSet.put(acc, color.ansi_color_code.code)
      end)

    MapSet.difference(ansi_color_code_set, color_set) |> MapSet.to_list() |> Enum.sort()
  end

  def create_names_for_missing_colors(all_colors, missing_names) do
    missing_names
    |> Enum.reduce(%{}, fn code, acc ->
      color = all_colors |> Enum.at(code) |> List.first()
      rename = new_color_name_to_atom("#{color.name}_#{color.ansi_color_code.hex}")
      renamed_color = %{color | name: rename}
      Map.put(acc, rename, renamed_color)
    end)
  end
end
