defmodule ColorNamesTest do
  use ExUnit.Case
  doctest ColorNames

  describe "functions which delegate to IO.ANSI" do
    test "reset() delegates to IO.ANSI" do
      assert ColorNames.reset() == IO.ANSI.reset()
    end
  end

  describe "ansi_color_codes/0" do
    test "returns the list of ansi color codes" do
      color_codes = ColorNames.ansi_color_codes()
      assert length(color_codes) == 256

      first_code = color_codes |> List.first()

      assert first_code == %{
               code: 0,
               hex: "000000",
               rgb: [0, 0, 0]
             }

      last_code = color_codes |> List.last()

      assert last_code == %{
               code: 255,
               hex: "eeeeee",
               rgb: [238, 238, 238]
             }
    end
  end

  describe "color_data/0" do
    test "returns the list of color data elements" do
      color_data = ColorNames.color_data()
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
end
