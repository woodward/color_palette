defmodule ColorPalette.ColorGroup do
  @moduledoc false

  @groups [:blue, :brown, :cyan, :gray_and_black, :green, :orange, :pink, :purple_violet_and_magenta, :red, :white, :yellow]

  def groups, do: @groups

  def ansi_color_codes_by_group(ansi_color_codes) do
    ansi_color_codes
    |> Enum.reduce(%{}, fn ansi_color_code, acc ->
      color_group = ansi_color_code.color_group

      if color_group == nil do
        acc
      else
        Map.update(acc, color_group, [ansi_color_code.code], &(&1 ++ [ansi_color_code.code]))
      end
    end)
  end
end
