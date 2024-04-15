#!/usr/bin/env elixir

Mix.install([
  {:color_palette, path: Path.join(__DIR__, "../")}
])

import IO.ANSI

defmodule FindMissing do
  @moduledoc false

  def find do
    colors = ColorPalette.new_all_colors_final()

    IO.puts(light_cyan() <> "All colors: #{length(Map.keys(colors))}" <> reset())

    ansi_color_codes = ColorPalette.ansi_color_codes()

    ansi_color_codes_set =
      ansi_color_codes |> Enum.reduce(MapSet.new(), fn ansi_color_code, acc -> MapSet.put(acc, ansi_color_code.code) end)

    colors_set =
      colors |> Enum.reduce(MapSet.new(), fn {_color_name, color}, acc -> MapSet.put(acc, color.ansi_color_code.code) end)

    missing = MapSet.difference(ansi_color_codes_set, colors_set) |> MapSet.to_list()
    IO.inspect(missing, label: "missing")
    IO.puts(light_yellow() <> "There are #{length(missing)} colors missing a name" <> reset())
  end
end

FindMissing.find()
