defmodule ColorPalette.DataConverter do
  @moduledoc false

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color
  alias ColorPalette.ColorGroup

  @spec normalize_data(map()) :: map()
  def normalize_data(color_data_api) do
    text_contrast_color =
      case color_data_api.contrast.value do
        "#ffffff" -> "white"
        "#000000" -> "black"
        _ -> raise "Unexpected doc text color"
      end

    %{
      name: color_data_api.name.value,
      distance_to_closest_named_hex: color_data_api.name.distance,
      text_contrast_color: text_contrast_color,
      exact_name_match?: color_data_api.name.exact_match_name,
      closest_named_hex: color_data_api.name.closest_named_hex |> String.replace("#", "")
    }
  end

  @spec convert_raw_color_data_to_colors([map()], Color.source()) :: [Color.t()]
  def convert_raw_color_data_to_colors(raw_color_data, source) do
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
          closest_named_hex: raw_color[:closest_named_hex]
        }
      end)
    end)
  end

  @spec add_ansi_color_codes_to_colors([Color.t()], [ANSIColorCode.t()]) :: [Color.t()]
  def add_ansi_color_codes_to_colors(color_data, ansi_color_codes) do
    Enum.zip(color_data, ansi_color_codes)
    |> Enum.map(fn {colors, ansi_color_code} ->
      colors
      |> Enum.map(fn color ->
        %Color{color | ansi_color_code: ansi_color_code}
      end)
    end)
  end

  @spec color_groups_to_ansi_color_codes([ANSIColorCode.t()], [ColorGroup.t()]) :: %{ColorGroup.t() => [ANSIColorCode.t()]}
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

  @spec color_name_to_atom(String.t()) :: [Color.color_name()]
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

  @spec annotate_same_as_field([Color.t()]) :: [Color.t()]
  def annotate_same_as_field(colors) do
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

  @spec color_names_to_colors([Color.t()]) :: %{Color.color_name() => [Color.t()]}
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

  @spec multi_zip(list()) :: list()
  def multi_zip(lists) do
    [first_list | remaining] = lists
    length_of_first_list = length(first_list)

    remaining
    |> Enum.each(fn list ->
      if length(list) != length_of_first_list do
        raise "The lists must all be of the same length"
      end
    end)

    initial_combined = List.duplicate([], length_of_first_list)

    lists
    |> Enum.reduce(initial_combined, fn list, acc ->
      Enum.zip(acc, list)
      |> Enum.map(fn {acc_list, elem_list} ->
        (acc_list ++ [elem_list]) |> List.flatten() |> Enum.reject(&(&1 == nil))
      end)
    end)
  end

  @spec ansi_color_codes_to_color_names([ANSIColorCode.t()], %{atom() => Color.t()}) :: %{ANSIColorCode.t() => [atom()]}
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

  @spec find_by_hex(%{Color.color_name() => Color.t()}, ANSIColorCode.hex()) :: [Color.t()]
  def find_by_hex(color_names, hex) do
    hex = hex |> String.replace("#", "")

    color_names
    |> Enum.filter(fn {_color_name, color} -> color.ansi_color_code.hex == hex end)
    |> Enum.map(fn {_color_name, color} -> color end)
    |> Enum.sort_by(& &1.name)
  end

  @spec find_by_code(%{Color.color_name() => Color.t()}, ANSIColorCode.code()) :: [Color.t()]
  def find_by_code(_color_names, code) when code < 0 or code > 255 do
    {:error, "Code #{code} is not valid"}
  end

  @spec find_by_code(%{Color.color_name() => Color.t()}, ANSIColorCode.code()) :: [Color.t()]
  def find_by_code(colors, code) do
    colors
    |> Enum.filter(fn {_color_name, color} -> color.ansi_color_code.code == code end)
    |> Enum.map(fn {_color_name, color} -> color end)
    |> Enum.sort_by(& &1.name)
  end

  @spec unnamed_ansi_color_codes(%{Color.color_name() => Color.t()}) :: [ANSIColorCode.code()]
  def unnamed_ansi_color_codes(color_map) do
    ansi_color_code_set = 0..255 |> Range.to_list() |> MapSet.new()

    color_set =
      color_map
      |> Enum.reduce(MapSet.new(), fn {_color_name, color}, acc ->
        MapSet.put(acc, color.ansi_color_code.code)
      end)

    MapSet.difference(ansi_color_code_set, color_set) |> MapSet.to_list() |> Enum.sort()
  end

  def create_names_for_missing_colors(all_colors, color_codes_missing_names) do
    color_codes_missing_names
    |> Enum.reduce(%{}, fn code, acc ->
      color = all_colors |> Enum.at(code) |> List.first()
      name_with_hex_suffix = color_name_to_atom("#{color.name}_#{color.ansi_color_code.hex}") |> List.first()
      renamed_color = %{color | name: name_with_hex_suffix, renamed?: true}
      Map.put(acc, name_with_hex_suffix, renamed_color)
    end)
  end

  def collate_colors_with_same_name_for_code(colors) do
    colors
    |> Enum.map(fn colors_for_code ->
      colors_for_code
      |> Enum.group_by(& &1.name)
      |> Enum.reduce([], fn {_color_name, colors_for_name}, acc ->
        colors_result =
          colors_for_name
          |> Enum.reduce(nil, fn color_for_name, acc ->
            if acc == nil do
              color_for_name
            else
              closest_named_hex = if acc.closest_named_hex, do: acc.closest_named_hex, else: color_for_name.closest_named_hex

              distance_to_closest_named_hex =
                if acc.distance_to_closest_named_hex do
                  acc.distance_to_closest_named_hex
                else
                  color_for_name.distance_to_closest_named_hex
                end

              exact_name_match? = if acc.exact_name_match?, do: acc.exact_name_match?, else: color_for_name.exact_name_match?

              %{
                color_for_name
                | source: acc.source ++ color_for_name.source,
                  closest_named_hex: closest_named_hex,
                  distance_to_closest_named_hex: distance_to_closest_named_hex,
                  exact_name_match?: exact_name_match?
              }
            end
          end)

        [colors_result] ++ acc
      end)
      |> Enum.reverse()
    end)
  end

  def purge_orphaned_same_as_entries(color_map) do
    color_map
    |> Enum.map(fn {color_name, color} ->
      purged_same_as = color.same_as |> Enum.reject(&(!Map.has_key?(color_map, &1)))
      {color_name, %{color | same_as: purged_same_as}}
    end)
    |> Enum.into(%{})
  end

  def group_by_name_frequency(ansi_colors) do
    ansi_colors
    |> Enum.sort_by(&length(&1))
    |> Enum.reduce(%{}, fn ansi_colors_for_code, acc1 ->
      ansi_colors_for_code
      |> Enum.reduce(acc1, fn color, acc2 ->
        # The first map entry for the color name "wins" and sticks around:
        Map.update(acc2, color.name, color, fn value -> value end)
      end)
    end)
  end
end
