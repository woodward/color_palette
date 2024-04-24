defmodule ColorPalette.DataConverter do
  @moduledoc """
  The functions in `ColorPalette.DataConverter` are all pure functions for testability (as opposed
  to those in `ColorPalette` which reference statically compiled data).
  """

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

  @spec annotate_same_as_field_for_codes_with_same_hex([Color.t()], %{ANSIColorCode.hex() => [ANSIColorCode.code()]}) ::
          [Color.t()]
  def annotate_same_as_field_for_codes_with_same_hex(colors, ansi_codes_with_same_hex) do
    ansi_codes_with_same_hex
    |> Enum.reduce(colors, fn {_hex, codes_for_same_hex}, acc1 ->
      codes_for_same_hex
      |> Enum.reduce(acc1, fn code, acc2 ->
        colors_at_code_index = acc2 |> Enum.at(code)
        other_indices = codes_for_same_hex |> Enum.reject(&(&1 == code))

        names_for_other_indices =
          other_indices
          |> Enum.reduce([], fn other_index, acc3 ->
            colors_at_other_index = colors |> Enum.at(other_index)

            names_at_other_index =
              colors_at_other_index
              |> Enum.reduce([], fn other_color, acc4 ->
                acc4 ++ [other_color.name]
              end)

            acc3 ++ names_at_other_index
          end)

        updated_colors_at_code_index =
          colors_at_code_index
          |> Enum.map(fn color ->
            %{color | same_as: color.same_as ++ names_for_other_indices}
          end)

        acc2 |> List.update_at(code, fn _value -> updated_colors_at_code_index end)
      end)
    end)
  end

  @spec annotate_same_as_field_for_duplicate_code_hexes(
          %{Color.name() => Color.t()},
          %{ANSIColorCode.hex() => [ANSIColorCode.code()]}
        ) ::
          %{Color.name() => Color.t()}
  def annotate_same_as_field_for_duplicate_code_hexes(colors, ansi_codes_with_same_hex_value) do
    names_for_codes_with_same_hex_value =
      ansi_codes_with_same_hex_value
      |> Enum.reduce(%{}, fn {hex, duplicate_codes}, acc ->
        names =
          duplicate_codes
          |> Enum.map(&find_by_code(colors, &1))
          |> List.flatten()
          |> Enum.map(& &1.name)
          # Not sure if this is needed, but does not hurt:
          |> Enum.uniq()

        Map.put(acc, hex, names)
      end)

    names_for_codes_with_same_hex_value
    |> Enum.reduce(colors, fn {hex, color_names}, acc1 ->
      colors
      |> find_by_hex(hex)
      |> Enum.reduce(acc1, fn color, acc2 ->
        same_as_augmented = (color.same_as ++ color_names) |> Enum.uniq() |> Enum.reject(&(&1 == color.name))
        color = %{color | same_as: same_as_augmented}
        Map.put(acc2, color.name, color)
      end)
    end)
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

  @spec multi_zip([[Color.t()]]) :: [[Color.t()]]
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

  @spec ansi_color_codes_to_color_names(
          [ANSIColorCode.t()],
          %{Color.name() => Color.t()},
          %{ANSIColorCode.hex() => [ANSIColorCode.code()]}
        ) ::
          %{ANSIColorCode.t() => [Color.name()]}
  def ansi_color_codes_to_color_names(ansi_color_codes, colors, ansi_codes_with_same_hex_value) do
    empty_ansi_color_codes_to_color_names =
      ansi_color_codes
      |> Enum.reduce(%{}, fn ansi_color_code, acc ->
        Map.put(acc, ansi_color_code, [])
      end)

    colors
    |> Enum.reduce(empty_ansi_color_codes_to_color_names, fn {color_name, color}, acc ->
      Map.update(acc, color.ansi_color_code, [color_name], &([color_name] ++ &1))
    end)
    |> Enum.map(fn {ansi_color_code, color_names} ->
      other_codes =
        ansi_codes_with_same_hex_value
        |> Map.get(ansi_color_code.hex)
        |> case do
          nil ->
            []

          other_codes ->
            other_codes
            |> Enum.reject(&(&1 == ansi_color_code.code))
            |> Enum.flat_map(fn other_code ->
              find_by_code(colors, other_code) |> Enum.map(& &1.name)
            end)
        end

      {ansi_color_code, (color_names ++ other_codes) |> Enum.sort()}
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
    {:error, "Code #{code} is not valid"}
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
      color = all_colors |> Enum.at(code) |> List.first()
      code = color.ansi_color_code.code |> Integer.to_string() |> String.pad_leading(3, "0")
      name_with_code_suffix = color_name_to_atom("#{color.name}_#{code}") |> List.first()
      renamed_color = %{color | name: name_with_code_suffix, renamed?: true}
      Map.put(acc, name_with_code_suffix, renamed_color)
    end)
  end

  @spec collate_colors_with_same_name_for_code([[Color.t()]]) :: [[Color.t()]]
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

  @spec purge_orphaned_same_as_entries(%{Color.name() => Color.t()}) :: %{Color.name() => Color.t()}
  def purge_orphaned_same_as_entries(color_map) do
    color_map
    |> Enum.map(fn {color_name, color} ->
      purged_same_as = color.same_as |> Enum.reject(&(!Map.has_key?(color_map, &1)))
      {color_name, %{color | same_as: purged_same_as}}
    end)
    |> Enum.into(%{})
  end

  @spec group_by_name_frequency([[Color.t()]]) :: %{Color.name() => Color.t()}
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
end
