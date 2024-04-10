#!/usr/bin/env elixir

Mix.install([
  {:color_palette, path: Path.join(__DIR__, "../")}
])

defmodule Display do
  import ColorPalette

  alias ColorPalette.ColorGroup

  def print_color(ansi_color_code, name) do
    code = ansi_color_code.code

    IO.puts(
      IO.ANSI.color(code) <>
        "This is color : " <> String.pad_leading(Integer.to_string(code), 4) <> "  Color: #{name}  " <> IO.ANSI.reset()
    )
  end

  def name_for_color(colors, ansi_color_code) do
    color = colors |> Enum.find(fn {_name, color} -> color.ansi_color_code.code == ansi_color_code.code end)

    if color == nil do
      "Unknown"
    else
      {name, _color_data} = color
      name
    end
  end

  def all do
    color_groups = ColorGroup.groups()
    colors = ColorPalette.colors()
    codes_without_color_groups = ColorPalette.ansi_color_codes() |> Enum.filter(&(&1.color_group == nil))

    codes_without_color_groups
    |> Enum.map(fn ansi_color_code ->
      name = name_for_color(colors, ansi_color_code)
      print_color(ansi_color_code, name)
    end)

    IO.puts("\n\n")

    IO.puts(light_yellow() <> "==================================================================================" <> reset())
    IO.puts("\n")

    color_groups
    |> Enum.each(fn group ->
      IO.puts("Group:  #{group}")
      IO.puts(" ")
      colors_for_group = ColorPalette.ansi_color_codes() |> Enum.filter(&(&1.color_group == group))

      colors_for_group
      |> Enum.each(fn ansi_color_code ->
        name = name_for_color(colors, ansi_color_code)
        print_color(ansi_color_code, name)
      end)
      IO.puts(light_yellow() <> "---------------------------------------------" <> reset())
    end)

    num_color_codes_without_color_groups = length(codes_without_color_groups)

    IO.puts(light_yellow() <> "==================================================================================" <> reset())
    IO.puts("\n")
    IO.puts(light_yellow() <> "There are #{num_color_codes_without_color_groups} with no color group" <> reset())
    IO.puts(light_yellow() <> "There are #{256 - num_color_codes_without_color_groups} WITH a color group" <> reset())
  end
end

Display.all()
