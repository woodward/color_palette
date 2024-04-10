defmodule ColorPalette.ColorNamesTest do
  @moduledoc false
  use ExUnit.Case

  alias ColorPalette.ColorNames
  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color

  describe "annotate" do
    test "adds color names and doc_text_color to ansi color codes" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data()
      colors = ColorNames.collate(color_codes, color_data)

      black = colors.black

      assert black.name == :black
      assert black.ansi_color_code == %ANSIColorCode{code: 16, hex: "000000", rgb: [0, 0, 0]}
      assert black.doc_text_color == :white
      assert length(black.color_data) == 2
    end

    test "sorts colors based on their distance" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data()
      colors = ColorNames.collate(color_codes, color_data)

      blueberry = colors.blueberry
      assert length(blueberry.color_data) == 5

      assert blueberry.ansi_color_code == %ANSIColorCode{code: 69, hex: "5f87ff", rgb: [95, 135, 255]}
      assert blueberry.doc_text_color == :black

      first_blueberry_color = blueberry.color_data |> List.first()
      assert first_blueberry_color.ansi_color_code == %ANSIColorCode{code: 69, hex: "5f87ff", rgb: [95, 135, 255]}
      assert first_blueberry_color.name.distance == 1685
      assert first_blueberry_color.hex.value == "#5F87FF"

      last_blueberry_color = blueberry.color_data |> List.last()

      assert last_blueberry_color.ansi_color_code == %ANSIColorCode{code: 99, hex: "875fff", rgb: [135, 95, 255]}
      assert last_blueberry_color.name.distance == 7219

      distances = blueberry.color_data |> Enum.map(& &1.name.distance)
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

    test "works for colors with dashes" do
      assert ColorNames.color_name_to_atom("Yellow-Green") == [:yellow_green]
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
      assert first.ansi_color_code == %ANSIColorCode{code: 0, color_group: :gray_and_black, hex: "000000", rgb: [0, 0, 0]}

      last = color_data |> List.last()
      assert last.ansi_color_code == %ANSIColorCode{code: 255, color_group: :gray_and_black, hex: "eeeeee", rgb: [238, 238, 238]}
    end
  end

  describe "collate_color_name_dot_com_data" do
    test "converts the color-name.com data into a map" do
      ansi_codes = ColorPalette.ansi_color_codes()
      color_name_dot_com_data = ColorPalette.color_name_dot_com_data()

      color_data = ColorNames.convert_color_name_dot_com_data(ansi_codes, color_name_dot_com_data)

      assert Map.keys(color_data) |> length() == 225

      alien_armpit = color_data.alien_armpit

      assert alien_armpit == %Color{
               name: :alien_armpit,
               doc_text_color: :black,
               ansi_color_code: %ANSIColorCode{code: 112, hex: "87d700", rgb: [135, 215, 0]}
             }
    end
  end

  describe "convert_ansi_colors_to_color_names" do
    test "works" do
      ansi_codes = ColorPalette.ansi_color_codes()
      ansi_colors = ColorPalette.io_ansi_colors()

      color_names = ColorNames.convert_ansi_colors_to_color_names(ansi_codes, ansi_colors)

      assert Map.keys(color_names) |> length() == 16
      black = color_names.black

      assert black == %Color{
               ansi_color_code: %ANSIColorCode{code: 0, color_group: :gray_and_black, hex: "000000", rgb: [0, 0, 0]},
               color_data: [],
               doc_text_color: :white,
               name: :black
             }
    end
  end

  describe "find_duplicates/1" do
    test "annotates the colors with duplicate function names" do
      color_names = %{
        black1: %Color{ansi_color_code: %ANSIColorCode{code: 1}},
        black2: %Color{ansi_color_code: %ANSIColorCode{code: 1}},
        some_other_color: %Color{ansi_color_code: %ANSIColorCode{code: 2}}
      }

      color_names_with_same_as = ColorNames.find_duplicates(color_names)

      assert color_names_with_same_as == %{
               black1: %Color{ansi_color_code: %ANSIColorCode{code: 1}, same_as: [:black2]},
               black2: %Color{ansi_color_code: %ANSIColorCode{code: 1}, same_as: [:black1]},
               some_other_color: %Color{ansi_color_code: %ANSIColorCode{code: 2}, same_as: []}
             }
    end
  end
end
