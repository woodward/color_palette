defmodule ColorPalette.DataConverterTest do
  @moduledoc false
  use ExUnit.Case

  alias ColorPalette.DataConverter
  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color

  describe "annotate" do
    test "adds color names and text_contrast_color to ansi color codes" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data_api_raw_data()
      colors = DataConverter.convert_color_data_api_raw_data(color_data, color_codes)

      black = colors.black

      assert black.name == :black
      assert black.ansi_color_code == %ANSIColorCode{code: 16, hex: "000000", color_group: :gray_and_black, rgb: [0, 0, 0]}
      assert black.text_contrast_color == :white
      assert black.source == :color_data_api
      assert length(black.color_data) == 2
    end

    test "sorts colors based on their distance" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data_api_raw_data()
      colors = DataConverter.convert_color_data_api_raw_data(color_data, color_codes)

      blueberry = colors.blueberry
      assert length(blueberry.color_data) == 5

      assert blueberry.ansi_color_code == %ANSIColorCode{code: 69, hex: "5f87ff", color_group: :blue, rgb: [95, 135, 255]}
      assert blueberry.text_contrast_color == :black
      assert blueberry.source == :color_data_api

      first_blueberry_color = blueberry.color_data |> List.first()

      assert first_blueberry_color.ansi_color_code == %ANSIColorCode{
               code: 69,
               hex: "5f87ff",
               color_group: :blue,
               rgb: [95, 135, 255]
             }

      assert first_blueberry_color.name.distance == 1685
      assert first_blueberry_color.hex.value == "#5F87FF"

      last_blueberry_color = blueberry.color_data |> List.last()

      assert last_blueberry_color.ansi_color_code == %ANSIColorCode{
               code: 99,
               hex: "875fff",
               color_group: :purple_violet_and_magenta,
               rgb: [135, 95, 255]
             }

      assert last_blueberry_color.name.distance == 7219

      distances = blueberry.color_data |> Enum.map(& &1.name.distance)
      assert distances == [1685, 3475, 3579, 6609, 7219]
    end
  end

  describe "color_groups_to_ansi_color_codes" do
    test "collates the ansi color codes by color group" do
      ansi_color_codes = [
        %ANSIColorCode{code: 0, hex: "000000", rgb: [0, 0, 0], color_group: :gray_and_black},
        %ANSIColorCode{code: 233, hex: "121212", rgb: [18, 18, 18], color_group: :gray_and_black},
        %ANSIColorCode{code: 191, hex: "d7ff5f", rgb: [215, 255, 95], color_group: :yellow},
        %ANSIColorCode{code: 161, hex: "d7005f", rgb: [215, 0, 95], color_group: nil}
      ]

      color_groups = [:gray_and_black, :yellow, :white]

      color_groups_to_ansi_color_codes = DataConverter.color_groups_to_ansi_color_codes(ansi_color_codes, color_groups)

      assert color_groups_to_ansi_color_codes == %{
               gray_and_black: [
                 %ANSIColorCode{code: 233, hex: "121212", rgb: [18, 18, 18], color_group: :gray_and_black},
                 %ANSIColorCode{code: 0, hex: "000000", rgb: [0, 0, 0], color_group: :gray_and_black}
               ],
               nil: [%ANSIColorCode{code: 161, hex: "d7005f", rgb: [215, 0, 95], color_group: nil}],
               yellow: [%ANSIColorCode{code: 191, hex: "d7ff5f", rgb: [215, 255, 95], color_group: :yellow}],
               white: []
             }
    end
  end

  describe "color_name_to_atom" do
    test "converts a color name to an atom" do
      assert DataConverter.color_name_to_atom("Black") == [:black]
    end

    test "snake cases multi-word colors" do
      assert DataConverter.color_name_to_atom("Rose of Sharon") == [:rose_of_sharon]
    end

    test "works for colors with apostrophes" do
      assert DataConverter.color_name_to_atom("Screamin' Green") == [:screamin_green]
    end

    test "works for colors with dashes" do
      assert DataConverter.color_name_to_atom("Yellow-Green") == [:yellow_green]
    end

    test "returns two colors if a slash" do
      assert DataConverter.color_name_to_atom("Magenta / Fuchsia") == [:magenta, :fuchsia]
    end
  end

  describe "add_ansi_code_to_colors" do
    test "adds the ANSI code to the color data" do
      ansi_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data_api_raw_data()
      color_data = DataConverter.add_ansi_code_to_colors(ansi_codes, color_data)

      first = color_data |> List.first()
      assert first.ansi_color_code == %ANSIColorCode{code: 0, color_group: :gray_and_black, hex: "000000", rgb: [0, 0, 0]}

      last = color_data |> List.last()
      assert last.ansi_color_code == %ANSIColorCode{code: 255, color_group: :gray_and_black, hex: "eeeeee", rgb: [238, 238, 238]}
    end
  end

  describe "find_by_hex" do
    setup do
      colors = %{
        mystic_pearl: %ColorPalette.Color{
          name: :mystic_pearl,
          ansi_color_code: %ColorPalette.ANSIColorCode{
            hex: "d75f87"
          }
        },
        spring_green_00ff5f: %ColorPalette.Color{
          name: :spring_green_00ff5f,
          ansi_color_code: %ColorPalette.ANSIColorCode{
            hex: "00ff5f"
          }
        },
        pompadour: %ColorPalette.Color{
          name: :pompadour,
          ansi_color_code: %ColorPalette.ANSIColorCode{
            hex: "5f005f"
          }
        }
      }

      [colors: colors]
    end

    test "returns the color with the specified hex value", %{colors: colors} do
      pompadour = DataConverter.find_by_hex(colors, "5f005f")
      assert pompadour.name == :pompadour
    end

    test "also works if there is a # in the hex value", %{colors: colors} do
      pompadour = DataConverter.find_by_hex(colors, "#5f005f")
      assert pompadour.name == :pompadour
    end

    test "returns an error if the hex value is not found", %{colors: colors} do
      result = DataConverter.find_by_hex(colors, "#aabbcc")
      assert result == {:error, "Hex value #aabbcc not found"}
    end
  end

  describe "find_by_code" do
    setup do
      colors = %{
        mystic_pearl: %ColorPalette.Color{
          name: :mystic_pearl,
          ansi_color_code: %ColorPalette.ANSIColorCode{
            code: 168
          }
        },
        spring_green_00ff5f: %ColorPalette.Color{
          name: :spring_green_00ff5f,
          ansi_color_code: %ColorPalette.ANSIColorCode{
            code: 48
          }
        },
        pompadour: %ColorPalette.Color{
          name: :pompadour,
          ansi_color_code: %ColorPalette.ANSIColorCode{
            code: 53
          }
        }
      }

      [colors: colors]
    end

    test "returns the color with the specified code", %{colors: colors} do
      pompadour = DataConverter.find_by_code(colors, 53)
      assert pompadour.name == :pompadour
    end

    test "returns an error if the code is not in the specified range", %{colors: colors} do
      result = DataConverter.find_by_code(colors, -1)
      assert result == {:error, "Code -1 is not valid"}

      result = DataConverter.find_by_code(colors, 257)
      assert result == {:error, "Code 257 is not valid"}
    end
  end

  describe "convert_color_data_api_raw_data_color_name_dot_com_raw_data" do
    test "converts the color-name.com data into a map" do
      ansi_codes = ColorPalette.ansi_color_codes()
      color_name_dot_com_raw_data = ColorPalette.color_name_dot_com_raw_data()

      color_data = DataConverter.convert_color_name_dot_com_raw_data(color_name_dot_com_raw_data, ansi_codes)

      assert Map.keys(color_data) |> length() == 225

      alien_armpit = color_data.alien_armpit

      assert alien_armpit == %Color{
               name: :alien_armpit,
               text_contrast_color: :black,
               ansi_color_code: %ANSIColorCode{code: 112, hex: "87d700", color_group: :green, rgb: [135, 215, 0]},
               source: :color_name_dot_com
             }
    end
  end

  describe "convert_ansi_colors_to_color_names" do
    test "works" do
      ansi_codes = ColorPalette.ansi_color_codes()
      ansi_colors = ColorPalette.io_ansi_color_names()

      color_names = DataConverter.convert_ansi_colors_to_color_names(ansi_colors, ansi_codes)

      assert Map.keys(color_names) |> length() == 16
      black = color_names.black

      assert black == %Color{
               ansi_color_code: %ANSIColorCode{code: 0, color_group: :gray_and_black, hex: "000000", rgb: [0, 0, 0]},
               color_data: [],
               text_contrast_color: :white,
               name: :black,
               source: :io_ansi
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

      color_names_with_same_as = DataConverter.find_duplicates(color_names)

      assert color_names_with_same_as == %{
               black1: %Color{ansi_color_code: %ANSIColorCode{code: 1}, same_as: [:black2]},
               black2: %Color{ansi_color_code: %ANSIColorCode{code: 1}, same_as: [:black1]},
               some_other_color: %Color{ansi_color_code: %ANSIColorCode{code: 2}, same_as: []}
             }
    end
  end

  describe "ansi_color_codes_to_color_names/2" do
    test "groups by ansi color codes" do
      ansi_color_codes = [%ANSIColorCode{code: 1}, %ANSIColorCode{code: 2}, %ANSIColorCode{code: 3}]

      color_names = %{
        black1: %Color{ansi_color_code: %ANSIColorCode{code: 1}},
        black2: %Color{ansi_color_code: %ANSIColorCode{code: 1}},
        some_other_color: %Color{ansi_color_code: %ANSIColorCode{code: 2}}
      }

      ansi_color_codes_to_color_names = DataConverter.ansi_color_codes_to_color_names(ansi_color_codes, color_names)

      assert ansi_color_codes_to_color_names == %{
               %ColorPalette.ANSIColorCode{code: 1} => [:black2, :black1],
               %ColorPalette.ANSIColorCode{code: 2} => [:some_other_color],
               %ColorPalette.ANSIColorCode{code: 3} => []
             }
    end
  end

  describe "clear_out_color_data" do
    test "clears out the color data array" do
      color_names = %{
        black: %Color{color_data: ["something"]},
        white: %Color{color_data: ["something else"]},
        yellow: %Color{color_data: []}
      }

      cleared_out = DataConverter.clear_out_color_data(color_names)

      assert cleared_out == %{
               black: %Color{color_data: []},
               white: %Color{color_data: []},
               yellow: %Color{color_data: []}
             }
    end
  end

  describe "io_ansi_colors_with_no_names" do
    test "returns a list of IO ansi color codes without a name" do
      colors = %{
        black1: %Color{ansi_color_code: %ANSIColorCode{code: 1}},
        black2: %Color{ansi_color_code: %ANSIColorCode{code: 1}},
        some_other_color: %Color{ansi_color_code: %ANSIColorCode{code: 2}}
      }

      ansi_color_codes = [%ANSIColorCode{code: 1}, %ANSIColorCode{code: 2}, %ANSIColorCode{code: 3}]
      color_codes_with_no_names = DataConverter.unnamed_ansi_color_codes(ansi_color_codes, colors)
      assert color_codes_with_no_names == [%ANSIColorCode{code: 3}]
    end
  end

  describe "backfill_missing_names/3" do
    test "gets other color names for codes which do not have a name" do
      ansi_color_codes = ColorPalette.ansi_color_codes()
      color_names = ColorPalette.colors_untransformed()
      color_data_api_raw_data = ColorPalette.color_data_api_raw_data()

      unnamed_ansi_color_codes = DataConverter.unnamed_ansi_color_codes(ansi_color_codes, color_names)
      assert length(unnamed_ansi_color_codes) == 21
      last_unnamed = unnamed_ansi_color_codes |> Enum.sort_by(& &1.code) |> List.last()
      assert last_unnamed == %ANSIColorCode{code: 246, color_group: :gray_and_black, hex: "949494", rgb: [148, 148, 148]}

      with_names_backfilled = DataConverter.backfill_missing_names(color_names, ansi_color_codes, color_data_api_raw_data)

      unnamed_ansi_color_codes_after_backfill = DataConverter.unnamed_ansi_color_codes(ansi_color_codes, with_names_backfilled)
      assert length(unnamed_ansi_color_codes_after_backfill) == 0

      gray_949494 = with_names_backfilled |> DataConverter.find_by_hex("949494")
      assert gray_949494.name == :gray_949494
      assert gray_949494.source == :color_data_api
      assert gray_949494.text_contrast_color == :black

      assert gray_949494.ansi_color_code == %ANSIColorCode{
               code: 246,
               color_group: :gray_and_black,
               hex: "949494",
               rgb: [148, 148, 148]
             }
    end
  end
end
