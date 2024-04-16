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
      color_data = ColorPalette.color_data_api_raw_data()
      assert length(color_data) == 256

      first_color_data = color_data |> List.first()

      assert first_color_data == %{
               XYZ: %{value: "XYZ(0, 0, 0)", X: 0, fraction: %{X: 0, Y: 0, Z: 0}, Y: 0, Z: 0},
               _embedded: %{},
               _links: %{self: %{href: "/id?hex=000000"}},
               cmyk: %{
                 value: "cmyk(NaN, NaN, NaN, 100)",
                 c: nil,
                 k: 100,
                 m: nil,
                 y: nil,
                 fraction: %{c: nil, k: 1, m: nil, y: nil}
               },
               contrast: %{value: "#ffffff"},
               hex: %{value: "#000000", clean: "000000"},
               hsl: %{value: "hsl(0, 0%, 0%)", s: 0, h: 0, l: 0, fraction: %{s: 0, h: 0, l: 0}},
               hsv: %{value: "hsv(0, 0%, 0%)", s: 0, v: 0, h: 0, fraction: %{s: 0, v: 0, h: 0}},
               image: %{
                 named: "https://www.thecolorapi.com/id?format=svg&hex=000000",
                 bare: "https://www.thecolorapi.com/id?format=svg&named=false&hex=000000"
               },
               name: %{value: "Black", closest_named_hex: "#000000", distance: 0, exact_match_name: true},
               rgb: %{value: "rgb(0, 0, 0)", r: 0, fraction: %{r: 0, b: 0, g: 0}, b: 0, g: 0}
             }

      last_color_data = color_data |> List.last()

      assert last_color_data == %{
               XYZ: %{
                 value: "XYZ(89, 93, 102)",
                 X: 89,
                 fraction: %{X: 0.8871333333333333, Y: 0.9333333333333333, Z: 1.0164},
                 Y: 93,
                 Z: 102
               },
               _embedded: %{},
               _links: %{self: %{href: "/id?hex=EEEEEE"}},
               cmyk: %{value: "cmyk(0, 0, 0, 7)", c: 0, k: 7, m: 0, y: 0, fraction: %{c: 0, k: 0.06666666666666665, m: 0, y: 0}},
               contrast: %{value: "#000000"},
               hex: %{value: "#EEEEEE", clean: "EEEEEE"},
               hsl: %{value: "hsl(0, 0%, 93%)", s: 0, h: 0, l: 93, fraction: %{s: 0, h: 0, l: 0.9333333333333333}},
               hsv: %{value: "hsv(0, 0%, 93%)", s: 0, v: 93, h: 0, fraction: %{s: 0, v: 0.9333333333333333, h: 0}},
               image: %{
                 named: "https://www.thecolorapi.com/id?format=svg&hex=EEEEEE",
                 bare: "https://www.thecolorapi.com/id?format=svg&named=false&hex=EEEEEE"
               },
               name: %{value: "Gallery", closest_named_hex: "#EFEFEF", distance: 5, exact_match_name: false},
               rgb: %{
                 value: "rgb(238, 238, 238)",
                 r: 238,
                 fraction: %{r: 0.9333333333333333, b: 0.9333333333333333, g: 0.9333333333333333},
                 b: 238,
                 g: 238
               }
             }
    end
  end

  describe "colors" do
    test "returns the map of color names to color data" do
      colors = ColorPalette.colors()
      assert length(Map.keys(colors)) == 505
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
    # Temporarily skip while refactor is in progress
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
               %{code: 0, name: :black, text_contrast_color: :white},
               %{code: 1, name: :red, text_contrast_color: :white},
               %{code: 2, name: :green, text_contrast_color: :white},
               %{code: 3, name: :yellow, text_contrast_color: :white},
               %{code: 4, name: :blue, text_contrast_color: :white},
               %{code: 5, name: :magenta, text_contrast_color: :white},
               %{code: 6, name: :cyan, text_contrast_color: :white},
               %{code: 7, name: :white, text_contrast_color: :black},
               %{code: 8, name: :light_black, text_contrast_color: :white},
               %{code: 9, name: :light_red, text_contrast_color: :white},
               %{code: 10, name: :light_green, text_contrast_color: :black},
               %{code: 11, name: :light_yellow, text_contrast_color: :black},
               %{code: 12, name: :light_blue, text_contrast_color: :white},
               %{code: 13, name: :light_magenta, text_contrast_color: :white},
               %{code: 14, name: :light_cyan, text_contrast_color: :black},
               %{code: 15, name: :light_white, text_contrast_color: :black}
             ]
    end
  end

  describe "find_by_hex" do
    test "returns the color with the specified hex value" do
      color = ColorPalette.find_by_hex("5f5fff")

      assert color == %Color{
               ansi_color_code: %ANSIColorCode{code: 63, color_group: :blue, hex: "5f5fff", rgb: [95, 95, 255]},
               closest_named_hex: "4F86F7",
               distance_to_closest_named_hex: 3579,
               exact_name_match?: false,
               name: :blueberry_5f5fff,
               same_as: [],
               source: [:color_data_api],
               text_contrast_color: :white
             }
    end
  end

  describe "find_by_code" do
    test "returns the color with the specified code" do
      color = ColorPalette.find_by_code(63)

      assert color == %Color{
               ansi_color_code: %ANSIColorCode{code: 63, color_group: :blue, hex: "5f5fff", rgb: [95, 95, 255]},
               closest_named_hex: "4F86F7",
               distance_to_closest_named_hex: 3579,
               exact_name_match?: false,
               name: :blueberry_5f5fff,
               same_as: [],
               source: [:color_data_api],
               text_contrast_color: :white
             }
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
                [:black_000000]}
    end
  end
end
