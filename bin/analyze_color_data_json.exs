#!/usr/bin/env elixir

Mix.install([
  {:jason, "~> 1.4"}
])

import IO.ANSI

color_data_file = Path.join(__DIR__, "../lib/color_palette/color_data_api_colors.json")
color_data = color_data_file |> File.read!() |> Jason.decode!(keys: :atoms)

# color_data = color_data |> Enum.take(3)

_names =
  color_data
  |> Enum.map(fn color_data ->
    name = color_data.name.value
    # IO.puts(light_yellow() <> name <> reset())
    name
  end)

with_multiple_names =
  color_data
  |> Enum.filter(fn color_data ->
    String.contains?(color_data.name.value, " / ")
  end)

_multiple_names = with_multiple_names |> Enum.map(& &1.name.value)

names_to_colors =
  color_data
  |> Enum.reduce(%{}, fn color_data, acc ->
    name = color_data.name.value
    Map.update(acc, name, [color_data], fn colors -> [color_data | colors] end)
  end)
  |> Enum.map(fn {name, colors} ->
    {name, colors |> Enum.sort_by(& &1.name.distance)}
  end)
  |> Enum.into(%{})

blueberry = Map.get(names_to_colors, "Blueberry")
# IO.inspect(blueberry)

IO.puts(light_blue() <> "Blueberry colors:" <> reset())

blueberry
|> Enum.map(fn color_data ->
  IO.puts(light_yellow() <> "#{color_data.name.distance}   #{color_data.hex.value}" <> reset())
end)
IO.puts(" ")

names_with_more_than_one_color =
  names_to_colors
  |> Enum.filter(fn {_name, colors} -> length(colors) > 1 end)

IO.puts(
  light_green() <>
    "There are #{length(names_with_more_than_one_color)} names with more than one color." <>
    reset()
)

names_with_more_than_one_color_simplified =
  names_with_more_than_one_color
  |> Enum.map(fn {name, colors} ->
    {name, colors |> Enum.map(& &1.hex.value)}
  end)

duplicate_hexes =
  names_with_more_than_one_color_simplified
  |> Enum.reduce(MapSet.new(), fn {_, hexes}, acc ->
    hexes
    |> Enum.reduce(acc, fn hex, acc ->
      MapSet.put(acc, hex)
    end)
  end)

IO.puts(light_yellow() <> "There are #{MapSet.size(duplicate_hexes)} duplicate hexes." <> reset())
