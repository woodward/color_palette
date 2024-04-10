defmodule ColorPaletteTest do
  use ExUnit.Case

  alias ColorPalette.ANSIColorCode

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
               hex: "000000",
               rgb: [0, 0, 0]
             }

      last_code = color_codes |> List.last()

      assert last_code == %ANSIColorCode{
               code: 255,
               hex: "eeeeee",
               rgb: [238, 238, 238]
             }
    end
  end

  describe "color_data/0" do
    test "returns the list of color data elements" do
      color_data = ColorPalette.color_data()
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
      assert length(Map.keys(colors)) == 358
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

  describe "io_ansi_colors/0" do
    test "returns the correct color code for one of the IO.ANSI color names" do
      io_ansi_name_to_code = ColorPalette.io_ansi_colors()

      assert io_ansi_name_to_code == %{
               black: %{code: 0, doc_text_color: :white},
               blue: %{code: 4, doc_text_color: :white},
               cyan: %{code: 6, doc_text_color: :white},
               green: %{code: 2, doc_text_color: :white},
               magenta: %{code: 5, doc_text_color: :white},
               red: %{code: 1, doc_text_color: :white},
               white: %{code: 7, doc_text_color: :black},
               yellow: %{code: 3, doc_text_color: :white},
               light_black: %{code: 8, doc_text_color: :white},
               light_blue: %{code: 12, doc_text_color: :white},
               light_cyan: %{code: 14, doc_text_color: :white},
               light_green: %{code: 10, doc_text_color: :white},
               light_magenta: %{code: 13, doc_text_color: :white},
               light_red: %{code: 9, doc_text_color: :white},
               light_white: %{code: 15, doc_text_color: :black},
               light_yellow: %{code: 11, doc_text_color: :white}
             }
    end
  end
end
