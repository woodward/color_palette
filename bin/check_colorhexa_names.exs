#!/usr/bin/env elixir

Mix.install([
  {:jason, "~> 1.4"},
  {:color_palette, path: Path.join(__DIR__, "../")}
])

import IO.ANSI

colorhexa_file = Path.join(__DIR__, "../lib/color_palette/data/colorhexa.com_colors.json")
colorhexa = colorhexa_file |> File.read!() |> Jason.decode!(keys: :atoms)

missing = ColorPalette.ansi_color_codes_without_names()
colors = ColorPalette.colors()

convert_to_color_name = fn color_name ->
  color_name
  |> String.replace(" ", "_")
  |> String.downcase()
  |> String.to_atom()
end

IO.puts(
  light_yellow() <>
    "There are " <> light_cyan() <> Integer.to_string(length(missing)) <> light_yellow() <> " colors missing names\n" <> reset()
)

colorhexa_would_help_with =
missing
|> Enum.reduce(0, fn code, acc ->
  colorhexa_value = colorhexa |> Enum.at(code)
  colorhexa_name = convert_to_color_name.(colorhexa_value.name)
  exists? = Map.has_key?(colors, colorhexa_name)
  color = if exists?, do: light_red(), else: light_green()

  IO.puts(
    light_yellow() <>
      "Code: #{String.pad_leading(inspect(code), 3)}" <>
      light_cyan() <>
      "  Colorhexa name: #{String.pad_leading(Atom.to_string(colorhexa_name), 40)}" <>
      color <> "  Name exists already? #{exists?}" <> reset()
  )
  if exists?, do: acc, else: acc + 1
end)

IO.puts(light_green() <> "\nColorhexa would help with about #{colorhexa_would_help_with} colors" <> reset())
