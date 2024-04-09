defmodule ColorPalette.ColorNames do
  @moduledoc false

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
      sorted_colors = sorted_colors |> Enum.map(&Map.put(&1, :doc_text_color, doc_text_color(&1)))
      {name, sorted_colors}
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
    |> Enum.map(&String.to_atom(&1))
  end

  def doc_text_color(color) do
    case color.contrast.value do
      "#ffffff" -> :white
      "#000000" -> :black
      _ -> raise "Unexpected doc text color"
    end
  end

  def add_code_to_color_data(ansi_codes, color_data) do
    Enum.zip(ansi_codes, color_data)
    |> Enum.map(fn {ansi_code, color_datum} ->
      Map.merge(color_datum, %{ansi_code: ansi_code.code})
    end)
  end
end
