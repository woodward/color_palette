defmodule ColorPaletteTest do
  use ExUnit.Case

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color

  describe "functions which delegate to IO.ANSI" do
    test "reset() delegates to IO.ANSI" do
      assert ColorPalette.reset() == IO.ANSI.reset()
    end
  end

  describe "ansi_color_codes/0" do
    test "returns the list of ansi color codes" do
      color_codes = ColorPalette.ansi_color_codes()
      assert length(color_codes) == 256

      first_code = color_codes |> List.first()

      assert first_code == %ANSIColorCode{
               code: 0,
               color_group: :gray_and_black,
               hex: "000000",
               rgb: [0, 0, 0]
             }

      last_code = color_codes |> List.last()

      assert last_code == %ANSIColorCode{
               code: 255,
               color_group: :gray_and_black,
               hex: "eeeeee",
               rgb: [238, 238, 238]
             }
    end
  end

  describe "color_groups_to_ansi_color_codes" do
    test "returns the mapping of color groups to ansi color codes" do
      color_groups_to_ansi_color_codes = ColorPalette.color_groups_to_ansi_color_codes()

      assert length(Map.keys(color_groups_to_ansi_color_codes)) == 11

      gray_and_black = color_groups_to_ansi_color_codes.gray_and_black
      assert length(gray_and_black) == 32
    end
  end

  describe "color_data/0" do
    test "returns the list of color data elements" do
      color_data = ColorPalette.raw_color_data_api_data()
      assert length(color_data) == 256

      first_color_data = color_data |> List.first()

      assert first_color_data == %{
               code: 0,
               name: "Black",
               closest_named_hex: "000000",
               distance_to_closest_named_hex: 0,
               exact_name_match?: true,
               text_contrast_color: "white"
             }

      last_color_data = color_data |> List.last()

      assert last_color_data == %{
               code: 255,
               name: "Gallery",
               closest_named_hex: "EFEFEF",
               distance_to_closest_named_hex: 5,
               exact_name_match?: false,
               text_contrast_color: "black"
             }
    end
  end

  describe "colors/1" do
    test "returns the map of color names to color data" do
      colors = ColorPalette.colors()
      assert length(Map.keys(colors)) == 485

      assert colors.olive == %Color{
               ansi_color_code: %ANSIColorCode{code: 3, color_group: :green, hex: "808000", rgb: [128, 128, 0]},
               closest_named_hex: "808000",
               distance_to_closest_named_hex: 0,
               exact_name_match?: true,
               name: :olive,
               renamed?: false,
               same_as: [],
               source: [:color_data_api, :color_name_dot_com, :colorhexa],
               text_contrast_color: :white
             }
    end
  end

  describe "color_names/0" do
    test "returns the list of color names" do
      colors = ColorPalette.color_names()
      assert length(colors) == 485
      first_five_names = colors |> Enum.take(5)
      assert first_five_names == [:aero_blue, :alien_armpit, :alto, :american_orange, :american_silver]
    end
  end

  describe "random_color_name/0" do
    test "returns a random color name" do
      random_color = ColorPalette.random_color_name()
      assert random_color in ColorPalette.color_names()
    end
  end

  describe "color functions" do
    test "creates functions for the various colors" do
      assert ColorPalette.aero_blue() == "\e[38;5;158m"
      assert ColorPalette.aero_blue_background() == "\e[48;5;158m"

      assert ColorPalette.mercury() == "\e[38;5;254m"
      assert ColorPalette.mercury_background() == "\e[48;5;254m"
    end
  end

  describe "standard IO.ANSI colors" do
    @tag :skip
    test "verify that the functions exist in ColorPalette for the standard IO.ANSI functions and that their outputs match" do
      assert ColorPalette.black() == IO.ANSI.black()
      assert ColorPalette.red() == IO.ANSI.red()
      assert ColorPalette.green() == IO.ANSI.green()
      assert ColorPalette.yellow() == IO.ANSI.yellow()
      assert ColorPalette.blue() == IO.ANSI.blue()
      assert ColorPalette.magenta() == IO.ANSI.magenta()
      assert ColorPalette.cyan() == IO.ANSI.cyan()
      assert ColorPalette.white() == IO.ANSI.white()

      assert ColorPalette.light_black() == IO.ANSI.light_black()
      assert ColorPalette.light_red() == IO.ANSI.light_red()
      assert ColorPalette.light_green() == IO.ANSI.light_green()
      assert ColorPalette.light_yellow() == IO.ANSI.light_yellow()
      assert ColorPalette.light_blue() == IO.ANSI.light_blue()
      assert ColorPalette.light_magenta() == IO.ANSI.light_magenta()
      assert ColorPalette.light_cyan() == IO.ANSI.light_cyan()
      assert ColorPalette.light_white() == IO.ANSI.light_white()

      assert ColorPalette.black_background() == IO.ANSI.black_background()
      assert ColorPalette.red_background() == IO.ANSI.red_background()
      assert ColorPalette.green_background() == IO.ANSI.green_background()
      assert ColorPalette.yellow_background() == IO.ANSI.yellow_background()
      assert ColorPalette.blue_background() == IO.ANSI.blue_background()
      assert ColorPalette.magenta_background() == IO.ANSI.magenta_background()
      assert ColorPalette.cyan_background() == IO.ANSI.cyan_background()
      assert ColorPalette.white_background() == IO.ANSI.white_background()

      assert ColorPalette.light_black_background() == IO.ANSI.light_black_background()
      assert ColorPalette.light_red_background() == IO.ANSI.light_red_background()
      assert ColorPalette.light_green_background() == IO.ANSI.light_green_background()
      assert ColorPalette.light_yellow_background() == IO.ANSI.light_yellow_background()
      assert ColorPalette.light_blue_background() == IO.ANSI.light_blue_background()
      assert ColorPalette.light_magenta_background() == IO.ANSI.light_magenta_background()
      assert ColorPalette.light_cyan_background() == IO.ANSI.light_cyan_background()
      assert ColorPalette.light_white_background() == IO.ANSI.light_white_background()
    end
  end

  describe "includes functions for the color-name.com colors" do
    test "these functions are defined" do
      assert ColorPalette.american_silver() == "\e[38;5;252m"
      assert ColorPalette.american_silver_background() == "\e[48;5;252m"

      assert ColorPalette.raisin_black() == "\e[38;5;235m"
      assert ColorPalette.raisin_black_background() == "\e[48;5;235m"

      assert ColorPalette.inchworm() == "\e[38;5;155m"
      assert ColorPalette.inchworm_background() == "\e[48;5;155m"
    end
  end

  describe "io_ansi_color_names/0" do
    test "returns the correct color code for one of the IO.ANSI color names" do
      io_ansi_name_to_code = ColorPalette.io_ansi_color_names()

      assert io_ansi_name_to_code == [
               %{
                 code: 0,
                 name: "black",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 1,
                 name: "red",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 2,
                 name: "green",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 3,
                 name: "yellow",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{code: 4, name: "blue", text_contrast_color: "white", distance_to_closest_named_hex: 0, exact_name_match?: true},
               %{
                 code: 5,
                 name: "magenta",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 6,
                 name: "cyan",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 7,
                 name: "white",
                 text_contrast_color: "black",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 8,
                 name: "light_black",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 9,
                 name: "light_red",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 10,
                 name: "light_green",
                 text_contrast_color: "black",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 11,
                 name: "light_yellow",
                 text_contrast_color: "black",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 12,
                 name: "light_blue",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 13,
                 name: "light_magenta",
                 text_contrast_color: "white",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 14,
                 name: "light_cyan",
                 text_contrast_color: "black",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               },
               %{
                 code: 15,
                 name: "light_white",
                 text_contrast_color: "black",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true
               }
             ]
    end
  end

  describe "find_by_hex" do
    test "returns the colors with the specified hex value (sorted by name)" do
      color = ColorPalette.find_by_hex("ff8787")

      assert color == [
               %Color{
                 name: :tulip,
                 ansi_color_code: %ANSIColorCode{code: 210, color_group: :red, hex: "ff8787", rgb: [255, 135, 135]},
                 text_contrast_color: :black,
                 closest_named_hex: "FF878D",
                 distance_to_closest_named_hex: 44,
                 source: [:color_data_api, :color_name_dot_com],
                 exact_name_match?: nil,
                 renamed?: false,
                 same_as: [:very_light_red]
               },
               %Color{
                 name: :very_light_red,
                 ansi_color_code: %ANSIColorCode{code: 210, color_group: :red, hex: "ff8787", rgb: [255, 135, 135]},
                 text_contrast_color: :black,
                 closest_named_hex: nil,
                 distance_to_closest_named_hex: nil,
                 source: [:colorhexa],
                 exact_name_match?: nil,
                 renamed?: false,
                 same_as: [:tulip]
               }
             ]
    end
  end

  describe "find_by_code" do
    test "returns the colors with the specified code (sorted by name)" do
      color = ColorPalette.find_by_code(211)

      assert color == [
               %Color{
                 name: :tickle_me_pink,
                 ansi_color_code: %ANSIColorCode{code: 211, color_group: :pink, hex: "ff87af", rgb: [255, 135, 175]},
                 text_contrast_color: :black,
                 closest_named_hex: "FC89AC",
                 distance_to_closest_named_hex: 320,
                 source: [:color_data_api, :color_name_dot_com],
                 exact_name_match?: nil,
                 renamed?: false,
                 same_as: [:very_light_pink]
               },
               %Color{
                 name: :very_light_pink,
                 ansi_color_code: %ANSIColorCode{code: 211, color_group: :pink, hex: "ff87af", rgb: [255, 135, 175]},
                 text_contrast_color: :black,
                 closest_named_hex: nil,
                 distance_to_closest_named_hex: nil,
                 source: [:colorhexa],
                 exact_name_match?: nil,
                 renamed?: false,
                 same_as: [:tickle_me_pink]
               }
             ]
    end

    test "returns an error if the code is not within 0-255" do
      assert ColorPalette.find_by_code(256) == {:error, "Code 256 is not valid; it must be between 0 - 255"}
      assert ColorPalette.find_by_code(-1) == {:error, "Code -1 is not valid; it must be between 0 - 255"}
    end
  end

  describe "find_by_source" do
    test "returns the colors as defined by their source" do
      io_ansi_colors = ColorPalette.find_by_source(:io_ansi)
      assert length(io_ansi_colors) == 10

      color_name_dot_com_colors = ColorPalette.find_by_source(:color_name_dot_com)
      assert length(color_name_dot_com_colors) == 217

      color_data_api_colors = ColorPalette.find_by_source(:color_data_api)
      assert length(color_data_api_colors) == 190

      colorhexa_colors = ColorPalette.find_by_source(:colorhexa)
      assert length(colorhexa_colors) == 130
    end
  end

  describe "ansi_color_codes_to_color_names" do
    test "returns a list of IO ansi color codes without a name" do
      ansi_color_codes_to_color_names = ColorPalette.ansi_color_codes_to_color_names()
      assert ansi_color_codes_to_color_names |> Map.keys() |> length() == 256

      key_values =
        ansi_color_codes_to_color_names
        |> Map.to_list()
        |> Enum.sort_by(fn {ansi_color_code, _} -> ansi_color_code.code end)

      first = key_values |> List.first()

      assert first ==
               {%ColorPalette.ANSIColorCode{code: 0, hex: "000000", rgb: [0, 0, 0], color_group: :gray_and_black},
                [:black, :black_016]}
    end
  end

  describe "figure out whether ColorPalette has all named Bunt colors" do
    test "checks on the named Bunt colors" do
      # Taken from:
      # https://github.com/rrrene/bunt/blob/master/lib/bunt_ansi.ex#L40
      # and the non-named colors were deleted:
      bunt_named_colors = [
        {"darkblue", :color18, 18, {0, 0, 135}},
        {"mediumblue", :color20, 20, {0, 0, 215}},
        {"darkgreen", :color22, 22, {0, 95, 0}},
        {"darkslategray", :color23, 23, {0, 95, 95}},
        {"darkcyan", :color30, 30, {0, 135, 135}},
        {"deepskyblue", :color39, 39, {0, 175, 255}},
        {"springgreen", :color48, 48, {0, 255, 135}},
        {"aqua", :color51, 51, {0, 255, 255}},
        {"dimgray", :color59, 59, {95, 95, 95}},
        {"steelblue", :color67, 67, {95, 135, 175}},
        {"darkred", :color88, 88, {135, 0, 0}},
        {"darkmagenta", :color90, 90, {135, 0, 135}},
        {"olive", :color100, 100, {135, 135, 0}},
        {"chartreuse", :color118, 118, {135, 255, 0}},
        {"aquamarine", :color122, 122, {135, 255, 215}},
        {"greenyellow", :color154, 154, {175, 255, 0}},
        {"chocolate", :color172, 172, {215, 135, 0}},
        {"goldenrod", :color178, 178, {215, 175, 0}},
        {"lightgray", :color188, 188, {215, 215, 215}},
        {"beige", :color194, 194, {215, 255, 215}},
        {"lightcyan", :color195, 195, {215, 255, 255}},
        {"fuchsia", :color201, 201, {255, 0, 255}},
        {"orangered", :color202, 202, {255, 95, 0}},
        {"hotpink", :color205, 205, {255, 95, 175}},
        {"darkorange", :color208, 208, {255, 135, 0}},
        {"coral", :color209, 209, {255, 135, 95}},
        {"orange", :color214, 214, {255, 175, 0}},
        {"gold", :color220, 220, {255, 215, 0}},
        {"khaki", :color222, 222, {255, 215, 135}},
        {"moccasin", :color223, 223, {255, 215, 175}},
        {"mistyrose", :color224, 224, {255, 215, 215}},
        {"lightyellow", :color230, 230, {255, 255, 215}}
      ]

      assert length(bunt_named_colors) == 32

      missing_by_code =
        bunt_named_colors
        |> Enum.reduce([], fn {bunt_name, _, code, _rgb_tuple}, acc ->
          names_for_color =
            ColorPalette.find_by_code(code)
            |> Enum.map(& &1.name)
            |> Enum.map(&(Atom.to_string(&1) |> String.replace("_", "")))

          if bunt_name in names_for_color, do: acc, else: [{bunt_name, code}] ++ acc
        end)
        |> Enum.reverse()

      assert length(missing_by_code) == 20

      assert missing_by_code == [
               {"darkslategray", 23},
               {"deepskyblue", 39},
               {"springgreen", 48},
               {"dimgray", 59},
               {"steelblue", 67},
               {"darkmagenta", 90},
               {"olive", 100},
               {"aquamarine", 122},
               {"greenyellow", 154},
               {"chocolate", 172},
               {"goldenrod", 178},
               {"beige", 194},
               {"lightcyan", 195},
               {"orangered", 202},
               {"darkorange", 208},
               {"orange", 214},
               {"khaki", 222},
               {"moccasin", 223},
               {"mistyrose", 224},
               {"lightyellow", 230}
             ]

      all_names = ColorPalette.colors() |> Map.keys() |> Enum.map(&(Atom.to_string(&1) |> String.replace("_", "")))

      missing_overall =
        bunt_named_colors
        |> Enum.reduce([], fn {bunt_name, _, code, _rgb_tuple}, acc ->
          if bunt_name in all_names, do: acc, else: [{bunt_name, code}] ++ acc
        end)
        |> Enum.reverse()

      assert length(missing_overall) == 11

      assert missing_overall == [
               {"darkslategray", 23},
               {"deepskyblue", 39},
               {"chocolate", 172},
               {"goldenrod", 178},
               {"beige", 194},
               {"orangered", 202},
               {"darkorange", 208},
               {"orange", 214},
               {"khaki", 222},
               {"moccasin", 223},
               {"mistyrose", 224}
             ]

      colors_in_color_palette_but_with_different_code =
        MapSet.new(missing_by_code)
        |> MapSet.difference(MapSet.new(missing_overall))
        |> MapSet.to_list()
        |> Enum.sort_by(fn {_, code} -> code end)

      assert length(colors_in_color_palette_but_with_different_code) == 9

      assert colors_in_color_palette_but_with_different_code == [
               {"springgreen", 48},
               {"dimgray", 59},
               {"steelblue", 67},
               {"darkmagenta", 90},
               {"olive", 100},
               {"aquamarine", 122},
               {"greenyellow", 154},
               {"lightcyan", 195},
               {"lightyellow", 230}
             ]
    end
  end
end
