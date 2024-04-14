defmodule ColorPalette.DataConverter do
  @moduledoc false

  alias ColorPalette.Color

  def convert_color_data_api_raw_data(color_data, ansi_color_codes) do
    ansi_color_codes
    |> deprecated_add_ansi_code_to_colors(color_data)
    |> Enum.reduce(%{}, fn color_data, acc ->
      names = color_data.name.value |> color_name_to_atom()

      names
      |> Enum.reduce(acc, fn name, acc ->
        Map.update(acc, name, [color_data], fn colors -> [color_data | colors] end)
      end)
    end)
    |> Enum.map(fn {name, colors} ->
      sorted_colors = colors |> Enum.sort_by(& &1.name.distance)
      first_color = sorted_colors |> List.first()

      color = %Color{
        name: name,
        color_data_deprecated: sorted_colors,
        ansi_color_code: first_color.ansi_color_code,
        text_contrast_color: text_contrast_color(first_color),
        source: :color_data_api
      }

      {name, color}
    end)
    |> Enum.into(%{})
  end

  def new_convert_color_data_api_raw_data(color_data, ansi_color_codes) do
    Enum.zip(color_data, ansi_color_codes)
    |> Enum.map(fn {raw_color, ansi_color_code} ->
      name = raw_color.name.value |> new_color_name_to_atom()
      distance_to_closest_named_hex = raw_color.name.distance
      exact_name_match? = raw_color.name.exact_match_name
      closest_named_hex = raw_color.name.closest_named_hex |> String.replace("#", "")

      %Color{
        name: name,
        ansi_color_code: ansi_color_code,
        text_contrast_color: text_contrast_color(raw_color),
        source: :color_data_api,
        distance_to_closest_named_hex: distance_to_closest_named_hex,
        exact_name_match?: exact_name_match?,
        closest_named_hex: closest_named_hex
      }
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

  def color_name_to_atom(name) do
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

  def deprecated_add_ansi_code_to_colors(ansi_color_codes, color_data) do
    Enum.zip(ansi_color_codes, color_data)
    |> Enum.map(fn {ansi_color_code, color_datum} ->
      Map.merge(color_datum, %{ansi_color_code: ansi_color_code})
    end)
  end

  def convert_color_name_dot_com_raw_data(color_name_dot_com_raw_data, ansi_color_codes) do
    deprecated_add_ansi_code_to_colors(ansi_color_codes, color_name_dot_com_raw_data)
    |> Enum.reduce(%{}, fn color_data, acc ->
      color_name = color_data.name |> color_name_to_atom() |> List.first()

      color = %Color{
        name: color_name,
        ansi_color_code: color_data.ansi_color_code,
        text_contrast_color: String.to_atom(color_data.text_contrast_color),
        source: :color_name_dot_com
      }

      Map.put(acc, color_name, color)
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
        source: :color_name_dot_com,
        exact_name_match?: false,
        distance_to_closest_named_hex: nil,
        closest_named_hex: nil
      }
    end)
  end

  def convert_ansi_colors_to_color_names(ansi_colors, ansi_color_codes) do
    ansi_colors
    |> Enum.reduce(%{}, fn {color_name, color_data}, acc ->
      ansi_color_code = ansi_color_codes |> Enum.find(&(&1.code == color_data.code))

      Map.put(acc, color_name, %Color{
        name: color_name,
        text_contrast_color: color_data.text_contrast_color,
        ansi_color_code: ansi_color_code,
        source: :io_ansi
      })
    end)
  end

  def new_convert_ansi_colors_to_color_names(ansi_colors, ansi_color_codes) do
    Enum.zip(ansi_colors, ansi_color_codes)
    |> Enum.map(fn {ansi_color, ansi_color_code} ->
      %Color{
        name: ansi_color.name,
        text_contrast_color: ansi_color.text_contrast_color,
        ansi_color_code: ansi_color_code,
        source: :io_ansi,
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

  def find_duplicates(color_names) do
    ansi_codes_to_names =
      color_names
      |> Enum.reduce(%{}, fn {color_name, color_data}, acc ->
        code = color_data.ansi_color_code.code
        Map.update(acc, code, [color_name], fn value -> [color_name] ++ value end)
      end)

    color_names
    |> Enum.map(fn {color_name, color_data} ->
      code = color_data.ansi_color_code.code
      colors_for_this_code = Map.get(ansi_codes_to_names, code) |> Enum.reject(&(&1 == color_name))
      {color_name, %{color_data | same_as: colors_for_this_code}}
    end)
    |> Enum.into(%{})
  end

  def clear_out_color_data_deprecated(color_names) do
    color_names
    |> Enum.map(fn {color_name, color} ->
      {color_name, %{color | color_data_deprecated: []}}
    end)
    |> Enum.into(%{})
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

  def unnamed_ansi_color_codes(ansi_color_codes, colors) do
    ansi_color_codes_to_color_names(ansi_color_codes, colors)
    |> Enum.reject(fn {_ansi_color_code, color_names} ->
      length(color_names) > 0
    end)
    |> Enum.map(fn {ansi_color_code, _color_names} -> ansi_color_code end)
  end

  def backfill_missing_names(color_names, ansi_color_codes, color_data_api_colors) do
    unnamed_ansi_color_codes = unnamed_ansi_color_codes(ansi_color_codes, color_names)

    unnamed_ansi_color_codes
    |> Enum.reduce(color_names, fn unnamed_ansi_color_code, acc ->
      missing_code = unnamed_ansi_color_code.code
      {raw_data, _rest} = List.pop_at(color_data_api_colors, missing_code)
      name = raw_data.name.value
      hex = raw_data.hex.clean
      rename = color_name_to_atom("#{name}_#{hex}") |> List.first()

      color = %Color{
        name: rename,
        ansi_color_code: unnamed_ansi_color_code,
        source: :color_data_api,
        text_contrast_color: text_contrast_color(raw_data)
      }

      Map.put(acc, rename, color)
    end)
  end
end
