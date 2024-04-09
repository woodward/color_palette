defmodule ColorPalette.ColorNamesTest do
  @moduledoc false
  use ExUnit.Case

  alias ColorPalette.ColorNames
  # alias ColorPalette.ANSIColorCode

  describe "annotate" do
    test "adds color names and doc_text_color to ansi color codes" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data()
      colors = ColorNames.collate(color_codes, color_data)

      black = colors.black

      black_color = black |> List.first()

      assert black_color.ansi_code == 16
      assert black_color.hex.value == "#000000"
      assert black_color.doc_text_color == :white

      # assert black.name == :black
      # assert black.ansi_color_code == %ANSIColorCode{code: 16, hex: "000000", rgb: [0, 0, 0]}
      # assert black.doc_text_color == :white
      # assert length(black.color_data) == 3
    end

    test "sorts colors based on their distance" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data()
      colors = ColorNames.collate(color_codes, color_data)

      blueberry = colors.blueberry
      assert length(blueberry) == 5

      blueberry_color = blueberry |> List.first()

      assert blueberry_color.ansi_code == 69
      assert blueberry_color.name.distance == 1685
      assert blueberry_color.hex.value == "#5F87FF"
      assert blueberry_color.doc_text_color == :black

      last_blueberry_color = blueberry |> List.last()

      assert last_blueberry_color.ansi_code == 99
      assert last_blueberry_color.name.distance == 7219

      distances = blueberry |> Enum.map(& &1.name.distance)
      assert distances == [1685, 3475, 3579, 6609, 7219]
    end
  end

  describe "color_name_to_atom" do
    test "converts a color name to an atom" do
      assert ColorNames.color_name_to_atom("Black") == [:black]
    end

    test "snake cases multi-word colors" do
      assert ColorNames.color_name_to_atom("Rose of Sharon") == [:rose_of_sharon]
    end

    test "works for colors with apostrophes" do
      assert ColorNames.color_name_to_atom("Screamin' Green") == [:screamin_green]
    end

    test "returns two colors if a slash" do
      assert ColorNames.color_name_to_atom("Magenta / Fuchsia") == [:magenta, :fuchsia]
    end
  end

  describe "add_code_to_color_data" do
    test "adds the ANSI code to the color data" do
      ansi_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data()
      color_data = ColorNames.add_code_to_color_data(ansi_codes, color_data)

      first = color_data |> List.first()
      assert first.ansi_code == 0

      last = color_data |> List.last()
      assert last.ansi_code == 255
    end
  end
end
