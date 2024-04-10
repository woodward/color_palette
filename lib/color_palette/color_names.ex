defmodule ColorPalette.ColorNames do
  @moduledoc false

  alias ColorPalette.Color

  def collate(ansi_color_codes, color_data) do
    ansi_color_codes
    |> add_code_to_color_data(color_data)
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

  def add_code_to_color_data(ansi_color_codes, color_data) do
    Enum.zip(ansi_color_codes, color_data)
    |> Enum.map(fn {ansi_color_code, color_datum} ->
      Map.merge(color_datum, %{ansi_color_code: ansi_color_code})
    end)
  end

  def convert_color_name_dot_com_data(ansi_color_codes, color_name_dot_com_data) do
    add_code_to_color_data(ansi_color_codes, color_name_dot_com_data)
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

  def convert_ansi_colors_to_color_names(ansi_color_codes, ansi_colors) do
    ansi_colors = ansi_colors |> Enum.flat_map(&[&1, String.to_atom("light_#{&1}")])

    ansi_colors
    |> Enum.reduce(%{}, fn ansi_color, acc ->
      ansi_code = Map.get(io_ansi_name_to_code(), ansi_color)
      ansi_color_code = ansi_color_codes |> Enum.find(&(&1.code == ansi_code))

      Map.put(acc, ansi_color, %Color{
        name: ansi_color,
        doc_text_color: :black,
        ansi_color_code: ansi_color_code
      })
    end)
  end

  def io_ansi_name_to_code do
    [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {color, code}, acc ->
      acc
      |> Map.put(color, code + 0)
      |> Map.put(String.to_atom("light_#{color}"), code + 8)

      # |> Map.put(String.to_atom("#{color}_background"), code + 40)
      # |> Map.put(String.to_atom("light_#{color}_background"), code + 100)

      # |> Map.put(color, code + 30)
      # |> Map.put(String.to_atom("light_#{color}"), code + 90)
      # |> Map.put(String.to_atom("#{color}_background"), code + 40)
      # |> Map.put(String.to_atom("light_#{color}_background"), code + 100)
    end)
  end
end
