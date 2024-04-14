defmodule ColorPalette.DataConverterTest do
  @moduledoc false
  use ExUnit.Case

  alias ColorPalette.DataConverter
  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color

  describe "new_convert_color_data_api_raw_data" do
    test "adds color names and text_contrast_color to ansi color codes" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data_api_raw_data()

      colors = DataConverter.new_convert_color_data_api_raw_data(color_data, color_codes)
      assert length(colors) == 256

      # ------------------------

      black = colors |> List.first()

      assert black.name == :black
      assert black.ansi_color_code == %ANSIColorCode{code: 0, hex: "000000", color_group: :gray_and_black, rgb: [0, 0, 0]}
      assert black.text_contrast_color == :white
      assert black.source == [:color_data_api]
      assert black.closest_named_hex == "000000"
      assert black.distance_to_closest_named_hex == 0
      assert black.exact_name_match? == true

      # ------------------------

      electric_violet = colors |> Enum.at(129)

      assert electric_violet.name == :electric_violet

      assert electric_violet.ansi_color_code == %ANSIColorCode{
               code: 129,
               color_group: :purple_violet_and_magenta,
               hex: "af00ff",
               rgb: [175, 0, 255]
             }

      assert electric_violet.text_contrast_color == :white
      assert electric_violet.source == [:color_data_api]
      assert electric_violet.closest_named_hex == "8B00FF"
      assert electric_violet.distance_to_closest_named_hex == 1368
      assert electric_violet.exact_name_match? == false

      # ------------------------

      magenta_fuschia = colors |> Enum.at(201)

      assert magenta_fuschia == [
               %ColorPalette.Color{
                 name: :magenta,
                 ansi_color_code: %ColorPalette.ANSIColorCode{code: 201, hex: "ff00ff", rgb: [255, 0, 255], color_group: :pink},
                 text_contrast_color: :black,
                 source: [:color_data_api],
                 closest_named_hex: "FF00FF",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true,
                 color_data_deprecated: [],
                 same_as: []
               },
               %ColorPalette.Color{
                 name: :fuchsia,
                 ansi_color_code: %ColorPalette.ANSIColorCode{code: 201, hex: "ff00ff", rgb: [255, 0, 255], color_group: :pink},
                 text_contrast_color: :black,
                 source: [:color_data_api],
                 closest_named_hex: "FF00FF",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true,
                 color_data_deprecated: [],
                 same_as: []
               }
             ]
    end
  end

  describe "annotate" do
    test "adds color names and text_contrast_color to ansi color codes" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data_api_raw_data()
      colors = DataConverter.convert_color_data_api_raw_data(color_data, color_codes)

      black = colors.black

      assert black.name == :black
      assert black.ansi_color_code == %ANSIColorCode{code: 16, hex: "000000", color_group: :gray_and_black, rgb: [0, 0, 0]}
      assert black.text_contrast_color == :white
      assert black.source == [:color_data_api]
      assert length(black.color_data_deprecated) == 2
    end

    test "sorts colors based on their distance" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data_api_raw_data()
      colors = DataConverter.convert_color_data_api_raw_data(color_data, color_codes)

      blueberry = colors.blueberry
      assert length(blueberry.color_data_deprecated) == 5

      assert blueberry.ansi_color_code == %ANSIColorCode{code: 69, hex: "5f87ff", color_group: :blue, rgb: [95, 135, 255]}
      assert blueberry.text_contrast_color == :black
      assert blueberry.source == [:color_data_api]

      first_blueberry_color = blueberry.color_data_deprecated |> List.first()

      assert first_blueberry_color.ansi_color_code == %ANSIColorCode{
               code: 69,
               hex: "5f87ff",
               color_group: :blue,
               rgb: [95, 135, 255]
             }

      assert first_blueberry_color.name.distance == 1685
      assert first_blueberry_color.hex.value == "#5F87FF"

      last_blueberry_color = blueberry.color_data_deprecated |> List.last()

      assert last_blueberry_color.ansi_color_code == %ANSIColorCode{
               code: 99,
               hex: "875fff",
               color_group: :purple_violet_and_magenta,
               rgb: [135, 95, 255]
             }

      assert last_blueberry_color.name.distance == 7219

      distances = blueberry.color_data_deprecated |> Enum.map(& &1.name.distance)
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

    test "gets rid of content in parens" do
      assert DataConverter.color_name_to_atom("Gold (Web)") == [:gold]
    end

    test "drops the é on :tenné" do
      assert DataConverter.color_name_to_atom("Tenné") == [:tenn]
    end
  end

  describe "deprecated_add_ansi_code_to_colors" do
    test "adds the ANSI code to the color data" do
      ansi_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data_api_raw_data()
      color_data = DataConverter.deprecated_add_ansi_code_to_colors(ansi_codes, color_data)

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
               source: [:color_name_dot_com]
             }
    end
  end

  describe "new_convert_color_name_dot_com_raw_data" do
    test "converts the color-name.com raw data into a list of Colors" do
      ansi_codes = ColorPalette.ansi_color_codes()
      color_name_dot_com_raw_data = ColorPalette.color_name_dot_com_raw_data()

      colors = DataConverter.new_convert_color_name_dot_com_raw_data(color_name_dot_com_raw_data, ansi_codes)

      assert length(colors) == 256

      alien_armpit = colors |> Enum.at(112)

      assert alien_armpit == %Color{
               name: :alien_armpit,
               text_contrast_color: :black,
               ansi_color_code: %ANSIColorCode{code: 112, hex: "87d700", color_group: :green, rgb: [135, 215, 0]},
               source: [:color_name_dot_com],
               closest_named_hex: nil,
               distance_to_closest_named_hex: nil,
               exact_name_match?: false
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
               color_data_deprecated: [],
               text_contrast_color: :white,
               name: :black,
               source: [:io_ansi]
             }
    end
  end

  describe "new_convert_ansi_colors_to_color_names" do
    test "works" do
      ansi_codes = ColorPalette.ansi_color_codes()
      ansi_colors = ColorPalette.new_io_ansi_color_names()

      colors = DataConverter.new_convert_ansi_colors_to_color_names(ansi_colors, ansi_codes)

      assert length(colors) == 16
      black = colors |> List.first()

      assert black == %Color{
               ansi_color_code: %ANSIColorCode{code: 0, color_group: :gray_and_black, hex: "000000", rgb: [0, 0, 0]},
               color_data_deprecated: [],
               text_contrast_color: :white,
               name: :black,
               source: [:io_ansi],
               exact_name_match?: true,
               distance_to_closest_named_hex: 0,
               closest_named_hex: nil
             }
    end
  end

  describe "combine_colors/3" do
    test "merges the three types of colors" do
      io_ansi_colors = ColorPalette.new_io_ansi_colors()
      color_data_api = ColorPalette.new_color_data_api_colors()
      color_name_dot_com = ColorPalette.new_color_name_dot_com_colors()

      combined = DataConverter.combine_colors(io_ansi_colors, color_data_api, color_name_dot_com)

      assert length(combined) == 256

      magenta = combined |> Enum.at(5)

      assert magenta == [
               %ColorPalette.Color{
                 name: :magenta,
                 ansi_color_code: %ColorPalette.ANSIColorCode{
                   code: 5,
                   hex: "800080",
                   rgb: [128, 0, 128],
                   color_group: :purple_violet_and_magenta
                 },
                 text_contrast_color: :white,
                 source: [:io_ansi],
                 closest_named_hex: nil,
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true,
                 color_data_deprecated: [],
                 same_as: []
               },
               %ColorPalette.Color{
                 name: :fresh_eggplant,
                 ansi_color_code: %ColorPalette.ANSIColorCode{
                   code: 5,
                   hex: "800080",
                   rgb: [128, 0, 128],
                   color_group: :purple_violet_and_magenta
                 },
                 text_contrast_color: :white,
                 source: [:color_data_api],
                 closest_named_hex: "990066",
                 distance_to_closest_named_hex: 1981,
                 exact_name_match?: false,
                 color_data_deprecated: [],
                 same_as: []
               },
               %ColorPalette.Color{
                 name: :patriarch,
                 ansi_color_code: %ColorPalette.ANSIColorCode{
                   code: 5,
                   hex: "800080",
                   rgb: [128, 0, 128],
                   color_group: :purple_violet_and_magenta
                 },
                 text_contrast_color: :white,
                 source: [:color_name_dot_com],
                 closest_named_hex: nil,
                 distance_to_closest_named_hex: nil,
                 exact_name_match?: false,
                 color_data_deprecated: [],
                 same_as: []
               }
             ]

      alien_armpit = combined |> Enum.at(112)

      assert alien_armpit == [
               %ColorPalette.Color{
                 name: :sheen_green,
                 ansi_color_code: %ColorPalette.ANSIColorCode{code: 112, hex: "87d700", rgb: [135, 215, 0], color_group: :green},
                 text_contrast_color: :black,
                 source: [:color_data_api],
                 closest_named_hex: "8FD400",
                 distance_to_closest_named_hex: 83,
                 exact_name_match?: false,
                 color_data_deprecated: [],
                 same_as: []
               },
               %ColorPalette.Color{
                 name: :alien_armpit,
                 ansi_color_code: %ColorPalette.ANSIColorCode{code: 112, hex: "87d700", rgb: [135, 215, 0], color_group: :green},
                 text_contrast_color: :black,
                 source: [:color_name_dot_com],
                 closest_named_hex: nil,
                 distance_to_closest_named_hex: nil,
                 exact_name_match?: false,
                 color_data_deprecated: [],
                 same_as: []
               }
             ]
    end
  end

  describe "new_color_names_to_colors" do
    test "groups colors by color names" do
      colors = [
        %ColorPalette.Color{
          name: :alien_armpit,
          ansi_color_code: %ColorPalette.ANSIColorCode{code: 112, hex: "87d700", rgb: [135, 215, 0], color_group: :green},
          text_contrast_color: :black,
          source: :color_name_dot_com,
          closest_named_hex: nil,
          distance_to_closest_named_hex: nil,
          exact_name_match?: false,
          color_data_deprecated: [],
          same_as: []
        },
        %ColorPalette.Color{
          name: :black,
          ansi_color_code: %ColorPalette.ANSIColorCode{code: 0, hex: "000000", rgb: [0, 0, 0], color_group: :gray_and_black},
          text_contrast_color: :white,
          source: :io_ansi,
          closest_named_hex: nil,
          distance_to_closest_named_hex: nil,
          exact_name_match?: false,
          color_data_deprecated: [],
          same_as: []
        },
        %ColorPalette.Color{
          name: :cyan,
          ansi_color_code: %ColorPalette.ANSIColorCode{code: 6, hex: "008080", rgb: [0, 128, 128], color_group: :cyan},
          text_contrast_color: :white,
          source: :io_ansi,
          closest_named_hex: nil,
          distance_to_closest_named_hex: nil,
          exact_name_match?: false,
          color_data_deprecated: [],
          same_as: [:teal]
        },
        %ColorPalette.Color{
          name: :cyan,
          ansi_color_code: %ColorPalette.ANSIColorCode{code: 45, hex: "00d7ff", rgb: [0, 215, 255], color_group: :blue},
          text_contrast_color: :black,
          source: :color_name_dot_com,
          closest_named_hex: nil,
          distance_to_closest_named_hex: nil,
          exact_name_match?: false,
          color_data_deprecated: [],
          same_as: []
        }
      ]

      grouped = DataConverter.new_color_names_to_colors(colors)

      assert grouped == %{
               cyan: [
                 %ColorPalette.Color{
                   name: :cyan,
                   ansi_color_code: %ColorPalette.ANSIColorCode{code: 45, hex: "00d7ff", rgb: [0, 215, 255], color_group: :blue},
                   text_contrast_color: :black,
                   source: :color_name_dot_com,
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: nil,
                   exact_name_match?: false,
                   color_data_deprecated: [],
                   same_as: []
                 },
                 %ColorPalette.Color{
                   ansi_color_code: %ColorPalette.ANSIColorCode{code: 6, color_group: :cyan, hex: "008080", rgb: [0, 128, 128]},
                   closest_named_hex: nil,
                   color_data_deprecated: [],
                   distance_to_closest_named_hex: nil,
                   exact_name_match?: false,
                   name: :cyan,
                   same_as: [:teal],
                   source: :io_ansi,
                   text_contrast_color: :white
                 }
               ],
               black: [
                 %ColorPalette.Color{
                   name: :black,
                   ansi_color_code: %ColorPalette.ANSIColorCode{
                     code: 0,
                     hex: "000000",
                     rgb: [0, 0, 0],
                     color_group: :gray_and_black
                   },
                   text_contrast_color: :white,
                   source: :io_ansi,
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: nil,
                   exact_name_match?: false,
                   color_data_deprecated: [],
                   same_as: []
                 }
               ],
               alien_armpit: [
                 %ColorPalette.Color{
                   name: :alien_armpit,
                   ansi_color_code: %ColorPalette.ANSIColorCode{code: 112, hex: "87d700", rgb: [135, 215, 0], color_group: :green},
                   text_contrast_color: :black,
                   source: :color_name_dot_com,
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: nil,
                   exact_name_match?: false,
                   color_data_deprecated: [],
                   same_as: []
                 }
               ]
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

  describe "clear_out_color_data_deprecated" do
    test "clears out the color data array" do
      color_names = %{
        black: %Color{color_data_deprecated: ["something"]},
        white: %Color{color_data_deprecated: ["something else"]},
        yellow: %Color{color_data_deprecated: []}
      }

      cleared_out = DataConverter.clear_out_color_data_deprecated(color_names)

      assert cleared_out == %{
               black: %Color{color_data_deprecated: []},
               white: %Color{color_data_deprecated: []},
               yellow: %Color{color_data_deprecated: []}
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
      assert gray_949494.source == [:color_data_api]
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
