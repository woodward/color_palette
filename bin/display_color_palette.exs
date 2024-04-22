#!/usr/bin/env elixir

Mix.install([
  {:color_palette, "~> 0.1"}
  # {:color_palette, path: Path.join(__DIR__, "../")}
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
      code = color.ansi_color_code.code

      IO.puts(
        apply(ColorPalette, name, []) <>
          "   This is color :#{String.pad_trailing(Atom.to_string(name), 26)}   ANSI Color Code: #{String.pad_leading(Integer.to_string(code), 3)}    Hex value: ##{hex}" <> reset()
      )
    end)
  end
end

IO.puts("\n\n")
Display.all()
Display.stats()
