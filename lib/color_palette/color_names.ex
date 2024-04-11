defmodule ColorPalette.ColorNames do
  @moduledoc false

  alias ColorPalette.Color

  def convert_color_data_api_data(color_data, ansi_color_codes) do
    ansi_color_codes
    |> add_ansi_code_to_colors(color_data)
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
        color_data: sorted_colors,
        ansi_color_code: first_color.ansi_color_code,
        doc_text_color: doc_text_color(first_color)
      }

      {name, color}
    end)
    |> Enum.into(%{})
  end

  def color_name_to_atom(name) do
    name
    |> String.downcase()
    |> String.split("/")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.replace(&1, " ", "_"))
    |> Enum.map(&String.replace(&1, "'", ""))
    |> Enum.map(&String.replace(&1, "-", "_"))
    |> Enum.map(&String.to_atom(&1))
  end

  def doc_text_color(color) do
    case color.contrast.value do
      "#ffffff" -> :white
      "#000000" -> :black
      _ -> raise "Unexpected doc text color"
    end
  end

  def add_ansi_code_to_colors(ansi_color_codes, color_data) do
    Enum.zip(ansi_color_codes, color_data)
    |> Enum.map(fn {ansi_color_code, color_datum} ->
      Map.merge(color_datum, %{ansi_color_code: ansi_color_code})
    end)
  end

  def convert_color_name_dot_com_data(color_name_dot_com_data, ansi_color_codes) do
    add_ansi_code_to_colors(ansi_color_codes, color_name_dot_com_data)
    |> Enum.reduce(%{}, fn color_data, acc ->
      color_name = color_data.name |> color_name_to_atom() |> List.first()

      color = %Color{
        name: color_name,
        ansi_color_code: color_data.ansi_color_code,
        doc_text_color: String.to_atom(color_data.doc_text_color)
      }

      Map.put(acc, color_name, color)
    end)
  end

  def convert_ansi_colors_to_color_names(ansi_colors, ansi_color_codes) do
    ansi_colors
    |> Enum.reduce(%{}, fn {color_name, color_data}, acc ->
      ansi_color_code = ansi_color_codes |> Enum.find(&(&1.code == color_data.code))

      Map.put(acc, color_name, %Color{
        name: color_name,
        doc_text_color: color_data.doc_text_color,
        ansi_color_code: ansi_color_code
      })
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
end
