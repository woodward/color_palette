defmodule ColorPalette.DataConverter do
  @moduledoc """
  The functions in `ColorPalette.DataConverter` are all pure functions for testability (as opposed
  to those in `ColorPalette` which reference statically compiled data).
  """

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color
  alias ColorPalette.ColorGroup

  @spec normalize_data(map(), ANSIColorCode.code()) :: map()
  def normalize_data(color_data_api_value, code) do
    text_contrast_color =
      case color_data_api_value.contrast.value do
        "#ffffff" -> "white"
        "#000000" -> "black"
        _ -> raise "Unexpected doc text color"
      end

    %{
      code: code,
      name: color_data_api_value.name.value,
      distance_to_closest_named_hex: color_data_api_value.name.distance,
      text_contrast_color: text_contrast_color,
      exact_name_match?: color_data_api_value.name.exact_match_name,
      closest_named_hex: color_data_api_value.name.closest_named_hex |> String.replace("#", "")
    }
  end

  @spec convert_raw_color_data_to_colors([map()], Color.source(), [ANSIColorCode.t()]) :: [[Color.t()]]
  def convert_raw_color_data_to_colors(raw_color_data, source, ansi_color_codes) do
    raw_color_data
    |> Enum.map(fn raw_color ->
      raw_color.name
      |> color_name_to_atom()
      |> Enum.map(fn color_name ->
        %Color{
          name: color_name,
          text_contrast_color: String.to_atom(raw_color.text_contrast_color),
          source: [source],
          exact_name_match?: raw_color[:exact_name_match?],
          distance_to_closest_named_hex: raw_color[:distance_to_closest_named_hex],
          closest_named_hex: raw_color[:closest_named_hex],
          ansi_color_code: ansi_color_codes |> Enum.at(raw_color.code)
        }
      end)
    end)
  end

  @spec color_groups_to_ansi_color_codes([ANSIColorCode.t()], [ColorGroup.t()]) :: %{ColorGroup.t() => [ANSIColorCode.t()]}
  def color_groups_to_ansi_color_codes(ansi_color_codes, color_groups) do
    # The block below is in case there are some color groups without any associated color codes,
    # which is no longer the case (there is at least one ANSI color code in each color group), but
    # I'm leaving this here regardless:
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

  @spec color_name_to_atom(String.t()) :: [Color.name()]
  def color_name_to_atom(name) do
    name
    |> String.downcase()
    |> String.replace(~r/\(.*\)/, "")
    |> String.replace(~r/é/, "")
    |> String.replace("[", "_")
    |> String.replace("]", "")
    |> String.split("/")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.split(&1, " - "))
    |> List.flatten()
    |> Enum.map(&String.replace(&1, " ", "_"))
    |> Enum.map(&String.replace(&1, "'", ""))
    |> Enum.map(&String.replace(&1, "-", "_"))
    |> Enum.map(&String.replace(&1, "__", "_"))
    |> Enum.map(&String.to_atom(&1))
  end

  @spec color_names_to_colors([Color.t()]) :: %{Color.name() => [Color.t()]}
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

  @spec ansi_color_codes_to_color_names([ANSIColorCode.t()], %{ANSIColorCode.hex() => [Color.name()]}) ::
          %{ANSIColorCode.t() => [Color.name()]}
  def ansi_color_codes_to_color_names(ansi_color_codes, hex_to_color_names) do
    ansi_color_codes
    |> Enum.reduce([], fn ansi_color_code, acc ->
      [{ansi_color_code, Map.get(hex_to_color_names, ansi_color_code.hex)}] ++ acc
    end)
    |> Enum.into(%{})
  end

  @spec find_by_hex(%{Color.name() => Color.t()}, ANSIColorCode.hex()) :: [Color.t()]
  def find_by_hex(color_names, hex) do
    hex = hex |> String.replace("#", "")

    color_names
    |> Enum.filter(fn {_color_name, color} -> color.ansi_color_code.hex == hex end)
    |> Enum.map(fn {_color_name, color} -> color end)
    |> Enum.sort_by(& &1.name)
  end

  @spec find_by_code(%{Color.name() => Color.t()}, ANSIColorCode.code()) :: [Color.t()]
  def find_by_code(_color_names, code) when code < 0 or code > 255 do
    {:error, "Code #{code} is not valid; it must be between 0 - 255"}
  end

  @spec find_by_code(%{Color.name() => Color.t()}, ANSIColorCode.code()) :: [Color.t()]
  def find_by_code(colors, code) do
    colors
    |> Enum.filter(fn {_color_name, color} -> color.ansi_color_code.code == code end)
    |> Enum.map(fn {_color_name, color} -> color end)
    |> Enum.sort_by(& &1.name)
  end

  @spec unnamed_ansi_color_codes(%{Color.name() => Color.t()}) :: [ANSIColorCode.code()]
  def unnamed_ansi_color_codes(color_map) do
    ansi_color_code_set = 0..255 |> Range.to_list() |> MapSet.new()

    color_set =
      color_map
      |> Enum.reduce(MapSet.new(), fn {_color_name, color}, acc ->
        MapSet.put(acc, color.ansi_color_code.code)
      end)

    MapSet.difference(ansi_color_code_set, color_set) |> MapSet.to_list() |> Enum.sort()
  end

  @spec create_names_for_missing_colors(%{Color.name() => Color.t()}, [ANSIColorCode.code()]) ::
          %{Color.name() => Color.t()}
  def create_names_for_missing_colors(all_colors, color_codes_missing_names) do
    color_codes_missing_names
    |> Enum.reduce(%{}, fn code, acc ->
      color = all_colors |> Enum.filter(&(&1.ansi_color_code.code == code)) |> List.first()
      code = color.ansi_color_code.code |> Integer.to_string() |> String.pad_leading(3, "0")
      name_with_code_suffix = color_name_to_atom("#{color.name}_#{code}") |> List.first()
      renamed_color = %{color | name: name_with_code_suffix, renamed?: true}
      Map.put(acc, name_with_code_suffix, renamed_color)
    end)
  end

  @spec combine_colors_with_same_name_and_code([Color.t()]) :: Color.t()
  def combine_colors_with_same_name_and_code(colors) do
    validate_input_for_combine_colors_fn!(colors)
    first_color = colors |> List.first()

    source = colors |> Enum.reduce([], fn color, acc -> color.source ++ acc end) |> Enum.sort()

    text_contrast_color =
      colors
      |> Enum.reduce([], fn color, acc -> [color.text_contrast_color] ++ acc end)
      |> Enum.uniq()
      |> Enum.sort()
      |> List.first()

    {closest_named_hex, distance_to_closest_named_hex, exact_name_match?} =
      colors
      |> Enum.reduce({nil, nil, false}, fn color, acc ->
        cond do
          color.exact_name_match? ->
            {color.closest_named_hex, 0, true}

          color.distance_to_closest_named_hex != nil ->
            if color.distance_to_closest_named_hex < elem(acc, 1) do
              {color.closest_named_hex, color.distance_to_closest_named_hex, false}
            else
              acc
            end

          true ->
            acc
        end
      end)

    %Color{
      name: first_color.name,
      ansi_color_code: first_color.ansi_color_code,
      text_contrast_color: text_contrast_color,
      source: source,
      distance_to_closest_named_hex: distance_to_closest_named_hex,
      closest_named_hex: closest_named_hex,
      exact_name_match?: exact_name_match?
    }
  end

  @spec validate_input_for_combine_colors_fn!([Color.t()]) :: :ok
  defp validate_input_for_combine_colors_fn!(colors) do
    color_names = colors |> Enum.map(& &1.name) |> Enum.uniq()

    if color_names |> length() > 1 do
      color_names_string = color_names |> Enum.map(&(":" <> Atom.to_string(&1))) |> Enum.join(", ")
      raise "Colors must all have the same name; instead got #{color_names_string}"
    end

    codes = colors |> Enum.map(& &1.ansi_color_code.code) |> Enum.uniq()

    if codes |> length() > 1 do
      codes_string = codes |> Enum.map(&Integer.to_string(&1)) |> Enum.join(", ")
      raise "Colors must all have the same ANSI color code; instead got #{codes_string}"
    end

    :ok
  end

  @spec combine_colors_with_same_name(%{Color.name() => [Color.t()]}) :: %{Color.name() => [Color.t()]}
  def combine_colors_with_same_name(colors) do
    colors
    |> Enum.map(fn {color_name, colors} ->
      combined_colors_for_same_name_and_code =
        colors
        |> Enum.group_by(& &1.ansi_color_code.code)
        |> Enum.reduce([], fn {_code, colors_for_code}, acc ->
          [combine_colors_with_same_name_and_code(colors_for_code)] ++ acc
        end)

      {color_name, combined_colors_for_same_name_and_code}
    end)
    |> Enum.into(%{})
  end

  @spec collate_colors_by_name([Color.t()]) :: %{Color.name() => [Color.t()]}
  def collate_colors_by_name(colors) do
    colors
    |> Enum.reduce(%{}, fn color, acc ->
      Map.update(acc, color.name, [color], &(&1 ++ [color]))
    end)
  end

  @spec codes_by_frequency_count(%{Color.name() => [Color.t()]}) :: %{ANSIColorCode => integer()}
  def codes_by_frequency_count(colors) do
    colors
    |> Enum.reduce(%{}, fn {_color_name, colors_for_name}, acc1 ->
      colors_for_name
      |> Enum.reduce(acc1, fn color, acc2 ->
        Map.update(acc2, color.ansi_color_code, 1, &(&1 + 1))
      end)
    end)
  end

  @spec group_by_name_frequency(%{Color.name() => [Color.t()]}) :: %{Color.name() => Color.t()}
  def group_by_name_frequency(colors) do
    code_frequencies = codes_by_frequency_count(colors)

    colors
    |> Enum.map(fn {color_name, colors} ->
      {color_name,
       colors
       |> Enum.sort_by(&Map.get(code_frequencies, &1.ansi_color_code))
       # The color with the lowest count "wins" (to try and get names for more of the ANSI color codes):
       |> List.first()}
    end)
    |> Enum.into(%{})
  end

  @spec hex_to_color_names(%{Color.name() => Color.t()}) :: %{ANSIColorCode.hex() => [Color.name()]}
  def hex_to_color_names(colors) do
    colors
    |> Enum.reduce(%{}, fn {_color_name, color}, acc ->
      hex = color.ansi_color_code.hex
      Map.update(acc, hex, [color.name], fn value -> value ++ [color.name] end)
    end)
    |> Enum.map(fn {hex, names} ->
      {hex, names |> Enum.sort()}
    end)
    |> Enum.into(%{})
  end

  @spec fill_in_same_as_field(%{Color.name() => Color.t()}, %{ANSIColorCode.hex() => [Color.name()]}) ::
          %{Color.name() => Color.t()}
  def fill_in_same_as_field(colors, hex_to_color_names) do
    colors
    |> Enum.map(fn {color_name, color} ->
      same_as =
        hex_to_color_names
        |> Map.get(color.ansi_color_code.hex)
        |> Enum.reject(&(&1 == color.name))
        |> Enum.sort()

      {color_name, %{color | same_as: same_as}}
    end)
    |> Enum.into(%{})
  end
end
