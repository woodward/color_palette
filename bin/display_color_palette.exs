#!/usr/bin/env elixir

Mix.install([
  {:color_palette, path: Path.join(__DIR__, "../")}
])

defmodule Display do
  import ColorPalette

  def stats do
    colors = ColorPalette.colors() |> Map.keys() |> length()
    IO.puts(yellow() <> "\nThere are #{colors} unique color names\n" <> reset())
  end

  def all do
    ColorPalette.colors()
    |> Enum.sort()
    |> Enum.map(fn {name, color} ->
      hex = color.ansi_color_code.hex

      IO.puts(
        apply(ColorPalette, name, []) <>
          "This is color :#{String.pad_trailing(Atom.to_string(name), 21)}  Hex value: ##{hex}" <> reset()
      )
    end)
  end
end

Display.all()
Display.stats()
