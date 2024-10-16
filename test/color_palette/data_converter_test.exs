defmodule ColorPalette.DataConverterTest do
  @moduledoc false
  use ExUnit.Case

  alias ColorPalette.DataConverter
  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color
  alias ColorPalette.PrecompileHook

  describe "convert_raw_color_data_api_to_colors" do
    test "adds color names and text_contrast_color to ansi color codes" do
      color_data = ColorPalette.raw_color_data_api_data()
      ansi_color_codes = ColorPalette.ansi_color_codes()

      colors = DataConverter.convert_raw_color_data_to_colors(color_data, :color_data_api, ansi_color_codes)
      assert length(colors) == 256

      # ------------------------

      [black] = colors |> List.first()

      assert black.name == :black
      assert black.ansi_color_code == %ANSIColorCode{code: 0, color_group: :gray_and_black, hex: "000000", rgb: [0, 0, 0]}
      assert black.text_contrast_color == :white
      assert black.source == [:color_data_api]
      assert black.closest_named_hex == "000000"
      assert black.distance_to_closest_named_hex == 0
      assert black.exact_name_match? == true

      # ------------------------

      [electric_violet] = colors |> Enum.at(129)

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
               %Color{
                 name: :magenta,
                 ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
                 text_contrast_color: :black,
                 source: [:color_data_api],
                 closest_named_hex: "FF00FF",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true,
                 same_as: []
               },
               %Color{
                 name: :fuchsia,
                 ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
                 text_contrast_color: :black,
                 source: [:color_data_api],
                 closest_named_hex: "FF00FF",
                 distance_to_closest_named_hex: 0,
                 exact_name_match?: true,
                 same_as: []
               }
             ]
    end
  end

  describe "convert colorhexa raw data" do
    test "adds color names and text_contrast_color to ansi color codes" do
      color_data = ColorPalette.raw_colorhexa_data()
      ansi_color_codes = ColorPalette.ansi_color_codes()

      colors = DataConverter.convert_raw_color_data_to_colors(color_data, :colorhexa, ansi_color_codes)
      assert length(colors) == 256

      # ------------------------

      [black] = colors |> List.first()

      assert black.name == :black
      assert black.ansi_color_code == %ANSIColorCode{code: 0, color_group: :gray_and_black, hex: "000000", rgb: [0, 0, 0]}
      assert black.text_contrast_color == :white
      assert black.source == [:colorhexa]
      assert black.closest_named_hex == nil
      assert black.distance_to_closest_named_hex == nil
      assert black.exact_name_match? == nil

      # ------------------------

      [pure_violet] = colors |> Enum.at(129)

      assert pure_violet.name == :pure_violet

      assert pure_violet.ansi_color_code == %ANSIColorCode{
               code: 129,
               color_group: :purple_violet_and_magenta,
               hex: "af00ff",
               rgb: [175, 0, 255]
             }

      assert pure_violet.text_contrast_color == :white
      assert pure_violet.source == [:colorhexa]
      assert pure_violet.closest_named_hex == nil
      assert pure_violet.distance_to_closest_named_hex == nil
      assert pure_violet.exact_name_match? == nil

      # ------------------------

      pale_cyan_and_lime_green = colors |> Enum.at(158)

      assert pale_cyan_and_lime_green == [
               %Color{
                 name: :pale_cyan,
                 ansi_color_code: %ANSIColorCode{code: 158, color_group: :cyan, hex: "afffd7", rgb: [175, 255, 215]},
                 text_contrast_color: :black,
                 closest_named_hex: nil,
                 distance_to_closest_named_hex: nil,
                 source: [:colorhexa],
                 exact_name_match?: nil,
                 same_as: []
               },
               %Color{
                 name: :lime_green,
                 ansi_color_code: %ANSIColorCode{code: 158, color_group: :cyan, hex: "afffd7", rgb: [175, 255, 215]},
                 text_contrast_color: :black,
                 closest_named_hex: nil,
                 distance_to_closest_named_hex: nil,
                 source: [:colorhexa],
                 exact_name_match?: nil,
                 same_as: []
               }
             ]
    end
  end

  describe "normalize_name_that_color_data/2" do
    test "adds in the :code and :text_contrast_color" do
      data_with_text_contrast_color = ColorPalette.raw_color_name_dot_com_data()
      name_that_color_data = File.read!("lib/color_palette/data/name_that_color_colors.json") |> PrecompileHook.jason_decode()
      normalized = DataConverter.normalize_name_that_color_data(name_that_color_data, data_with_text_contrast_color)

      assert length(normalized) == 261

      first = normalized |> List.first()
      assert first == %{code: 0, name: :black, text_contrast_color: "white"}

      last = normalized |> List.last()
      assert last == %{code: 255, name: :gallery, text_contrast_color: "black"}
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

    test "drops the '(mostly black)' phrase on colorhexa names" do
      assert DataConverter.color_name_to_atom("Very dark gray (mostly black)") == [:very_dark_gray]
    end

    test "drops the '(or mostly pure)' phrase on colorhexa names" do
      assert DataConverter.color_name_to_atom("Pure (or mostly pure) orange") == [:pure_orange]
    end

    test "changes the '[Pink tone]' phrase on colorhexa names" do
      assert DataConverter.color_name_to_atom("Very pale red [Pink tone]") == [:very_pale_red_pink_tone]
    end

    test "changes the '[Olive tone]' phrase on colorhexa names" do
      assert DataConverter.color_name_to_atom("Dark yellow [Olive tone]") == [:dark_yellow_olive_tone]
    end

    test "splits colorhexa names with a dash" do
      assert DataConverter.color_name_to_atom("Very light cyan - lime green") == [:very_light_cyan, :lime_green]
    end
  end

  describe "find_by_hex" do
    setup do
      colors = %{
        mystic_pearl: %Color{
          name: :mystic_pearl,
          ansi_color_code: %ANSIColorCode{
            hex: "d75f87"
          }
        },
        spring_green_00ff5f: %Color{
          name: :spring_green_00ff5f,
          ansi_color_code: %ANSIColorCode{
            hex: "00ff5f"
          }
        },
        pompadour: %Color{
          name: :pompadour,
          ansi_color_code: %ANSIColorCode{
            hex: "5f005f"
          }
        }
      }

      [colors: colors]
    end

    test "returns the color with the specified hex value", %{colors: colors} do
      [pompadour] = DataConverter.find_by_hex(colors, "5f005f")
      assert pompadour.name == :pompadour
    end

    test "also works if there is a # in the hex value", %{colors: colors} do
      [pompadour] = DataConverter.find_by_hex(colors, "#5f005f")
      assert pompadour.name == :pompadour
    end

    test "returns an empty list if the hex value is not found", %{colors: colors} do
      result = DataConverter.find_by_hex(colors, "#aabbcc")
      assert result == []
    end
  end

  describe "find_by_code" do
    setup do
      colors = %{
        mystic_pearl: %Color{
          name: :mystic_pearl,
          ansi_color_code: %ANSIColorCode{
            code: 168
          }
        },
        spring_green_00ff5f: %Color{
          name: :spring_green_00ff5f,
          ansi_color_code: %ANSIColorCode{
            code: 48
          }
        },
        pompadour: %Color{
          name: :pompadour,
          ansi_color_code: %ANSIColorCode{
            code: 53
          }
        }
      }

      [colors: colors]
    end

    test "returns the color with the specified code", %{colors: colors} do
      [pompadour] = DataConverter.find_by_code(colors, 53)
      assert pompadour.name == :pompadour
    end

    test "returns an error if the code is not in the specified range", %{colors: colors} do
      result = DataConverter.find_by_code(colors, -1)
      assert result == {:error, "Code -1 is not valid; it must be between 0 - 255"}

      result = DataConverter.find_by_code(colors, 256)
      assert result == {:error, "Code 256 is not valid; it must be between 0 - 255"}
    end
  end

  describe "convert_raw_color_data_to_colors" do
    test "converts the color-name.com raw data into a list of Colors" do
      raw_color_name_dot_com_data = ColorPalette.raw_color_name_dot_com_data()
      ansi_color_codes = ColorPalette.ansi_color_codes()

      colors = DataConverter.convert_raw_color_data_to_colors(raw_color_name_dot_com_data, :color_name_dot_com, ansi_color_codes)

      assert length(colors) == 256

      [alien_armpit] = colors |> Enum.at(112)

      assert alien_armpit == %Color{
               name: :alien_armpit,
               text_contrast_color: :black,
               ansi_color_code: %ANSIColorCode{code: 112, color_group: :green, hex: "87d700", rgb: [135, 215, 0]},
               source: [:color_name_dot_com],
               closest_named_hex: nil,
               distance_to_closest_named_hex: nil,
               exact_name_match?: nil
             }
    end
  end

  describe "convert_ansi_colors_to_colors" do
    test "works" do
      ansi_colors = ColorPalette.io_ansi_color_names()
      ansi_color_codes = ColorPalette.ansi_color_codes()

      colors = DataConverter.convert_raw_color_data_to_colors(ansi_colors, :io_ansi, ansi_color_codes)

      assert length(colors) == 16
      [black] = colors |> List.first()

      assert black == %Color{
               ansi_color_code: %ANSIColorCode{code: 0, color_group: :gray_and_black, hex: "000000", rgb: [0, 0, 0]},
               text_contrast_color: :white,
               name: :black,
               source: [:io_ansi],
               exact_name_match?: true,
               distance_to_closest_named_hex: 0,
               closest_named_hex: nil
             }
    end
  end

  describe "color_names_to_colors" do
    test "groups colors by color names" do
      colors = [
        %Color{
          name: :alien_armpit,
          ansi_color_code: %ANSIColorCode{code: 112, hex: "87d700", rgb: [135, 215, 0], color_group: :green},
          text_contrast_color: :black,
          source: :color_name_dot_com,
          closest_named_hex: nil,
          distance_to_closest_named_hex: nil,
          exact_name_match?: false,
          same_as: []
        },
        %Color{
          name: :black,
          ansi_color_code: %ANSIColorCode{code: 0, hex: "000000", rgb: [0, 0, 0], color_group: :gray_and_black},
          text_contrast_color: :white,
          source: :io_ansi,
          closest_named_hex: nil,
          distance_to_closest_named_hex: nil,
          exact_name_match?: false,
          same_as: []
        },
        %Color{
          name: :cyan,
          ansi_color_code: %ANSIColorCode{code: 6, hex: "008080", rgb: [0, 128, 128], color_group: :cyan},
          text_contrast_color: :white,
          source: :io_ansi,
          closest_named_hex: nil,
          distance_to_closest_named_hex: nil,
          exact_name_match?: false,
          same_as: [:teal]
        },
        %Color{
          name: :cyan,
          ansi_color_code: %ANSIColorCode{code: 45, hex: "00d7ff", rgb: [0, 215, 255], color_group: :blue},
          text_contrast_color: :black,
          source: :color_name_dot_com,
          closest_named_hex: nil,
          distance_to_closest_named_hex: nil,
          exact_name_match?: false,
          same_as: []
        }
      ]

      grouped = DataConverter.color_names_to_colors(colors)

      assert grouped == %{
               cyan: [
                 %Color{
                   name: :cyan,
                   ansi_color_code: %ANSIColorCode{code: 45, hex: "00d7ff", rgb: [0, 215, 255], color_group: :blue},
                   text_contrast_color: :black,
                   source: :color_name_dot_com,
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: nil,
                   exact_name_match?: false,
                   same_as: []
                 },
                 %Color{
                   ansi_color_code: %ANSIColorCode{code: 6, color_group: :cyan, hex: "008080", rgb: [0, 128, 128]},
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: nil,
                   exact_name_match?: false,
                   name: :cyan,
                   same_as: [:teal],
                   source: :io_ansi,
                   text_contrast_color: :white
                 }
               ],
               black: [
                 %Color{
                   name: :black,
                   ansi_color_code: %ANSIColorCode{
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
                   same_as: []
                 }
               ],
               alien_armpit: [
                 %Color{
                   name: :alien_armpit,
                   ansi_color_code: %ANSIColorCode{code: 112, hex: "87d700", rgb: [135, 215, 0], color_group: :green},
                   text_contrast_color: :black,
                   source: :color_name_dot_com,
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: nil,
                   exact_name_match?: false,
                   same_as: []
                 }
               ]
             }
    end
  end

  describe "hex_to_color_names/1" do
    test "groups by ansi color codes" do
      colors = %{
        black1: %Color{name: :black1, ansi_color_code: %ANSIColorCode{code: 1, hex: "000000"}},
        black2: %Color{name: :black2, ansi_color_code: %ANSIColorCode{code: 1, hex: "000000"}},
        some_other_color: %Color{name: :some_other_color, ansi_color_code: %ANSIColorCode{code: 2, hex: "aaaaaa"}},
        black3: %Color{name: :black3, ansi_color_code: %ANSIColorCode{code: 3, hex: "000000"}}
      }

      hex_to_color_names = DataConverter.hex_to_color_names(colors)

      assert hex_to_color_names == %{
               "000000" => [:black1, :black2, :black3],
               "aaaaaa" => [:some_other_color]
             }
    end
  end

  describe "ansi_color_codes_to_color_names/3" do
    test "groups color names by hex values" do
      ansi_color_codes = [
        %ANSIColorCode{code: 1, hex: "000000"},
        %ANSIColorCode{code: 2, hex: "aaaaaa"},
        %ANSIColorCode{code: 3, hex: "000000"}
      ]

      hex_to_color_names = %{
        "000000" => [:black1, :black2],
        "aaaaaa" => [:some_color]
      }

      ansi_color_codes_to_color_names = DataConverter.ansi_color_codes_to_color_names(ansi_color_codes, hex_to_color_names)

      assert ansi_color_codes_to_color_names == %{
               %ANSIColorCode{code: 1, hex: "000000"} => [:black1, :black2],
               %ANSIColorCode{code: 2, hex: "aaaaaa"} => [:some_color],
               %ANSIColorCode{code: 3, hex: "000000"} => [:black1, :black2]
             }
    end
  end

  describe "fill_in_same_as_field/2" do
    test "fills in the :same_as field" do
      hex_to_color_names = %{
        "000000" => [:black1, :black2, :black3],
        "aaaaaa" => [:some_other_color]
      }

      colors = %{
        black1: %Color{name: :black1, ansi_color_code: %ANSIColorCode{code: 1, hex: "000000"}},
        black2: %Color{name: :black2, ansi_color_code: %ANSIColorCode{code: 1, hex: "000000"}},
        some_other_color: %Color{name: :some_other_color, ansi_color_code: %ANSIColorCode{code: 2, hex: "aaaaaa"}},
        black3: %Color{name: :black3, ansi_color_code: %ANSIColorCode{code: 3, hex: "000000"}}
      }

      annotated_colors = DataConverter.fill_in_same_as_field(colors, hex_to_color_names)

      assert annotated_colors == %{
               black1: %Color{
                 name: :black1,
                 same_as: [:black2, :black3],
                 ansi_color_code: %ANSIColorCode{code: 1, hex: "000000"}
               },
               black2: %Color{
                 name: :black2,
                 same_as: [:black1, :black3],
                 ansi_color_code: %ANSIColorCode{code: 1, hex: "000000"}
               },
               some_other_color: %Color{
                 name: :some_other_color,
                 same_as: [],
                 ansi_color_code: %ANSIColorCode{code: 2, hex: "aaaaaa"}
               },
               black3: %Color{
                 name: :black3,
                 same_as: [:black1, :black2],
                 ansi_color_code: %ANSIColorCode{code: 3, hex: "000000"}
               }
             }
    end
  end

  describe "unnamed_ansi_color_codes" do
    test "returns a list of IO ansi color codes without a name" do
      colors = ColorPalette.colors_by_name()

      color_codes_with_no_names = DataConverter.unnamed_ansi_color_codes(colors)

      assert length(color_codes_with_no_names) == 17

      expected = [0, 3, 4, 6, 10, 11, 12, 13, 14, 42, 47, 56, 86, 87, 99, 121, 163]
      assert color_codes_with_no_names == expected
    end
  end

  describe "create_names_for_missing_colors/2" do
    test "creates some fake color names for colors which are missing names" do
      all_colors = ColorPalette.combined_colors()
      missing_names = [22, 33]
      new_names = DataConverter.create_names_for_missing_colors(all_colors, missing_names)

      assert new_names == %{
               azure_radiance_033: %Color{
                 name: :azure_radiance_033,
                 ansi_color_code: %ANSIColorCode{code: 33, hex: "0087ff", rgb: [0, 135, 255], color_group: :blue},
                 text_contrast_color: :black,
                 closest_named_hex: "007FFF",
                 distance_to_closest_named_hex: 66,
                 source: [:color_data_api],
                 exact_name_match?: false,
                 same_as: [],
                 renamed?: true
               },
               camarone_022: %Color{
                 name: :camarone_022,
                 ansi_color_code: %ANSIColorCode{code: 22, hex: "005f00", rgb: [0, 95, 0], color_group: :green},
                 text_contrast_color: :white,
                 closest_named_hex: "00581A",
                 distance_to_closest_named_hex: 1031,
                 source: [:color_data_api],
                 exact_name_match?: false,
                 same_as: [],
                 renamed?: true
               }
             }
    end
  end

  describe "collate_colors_by_name/1 - not in use yet" do
    test "groups the colors under color names" do
      colors = [
        %Color{name: :black, ansi_color_code: %ANSIColorCode{code: 0}},
        %Color{name: :black, ansi_color_code: %ANSIColorCode{code: 16}},
        %Color{name: :red, ansi_color_code: %ANSIColorCode{code: 196}}
      ]

      color_map = DataConverter.collate_colors_by_name(colors)

      assert color_map == %{
               black: [
                 %Color{name: :black, ansi_color_code: %ANSIColorCode{code: 0}},
                 %Color{name: :black, ansi_color_code: %ANSIColorCode{code: 16}}
               ],
               red: [%Color{name: :red, ansi_color_code: %ANSIColorCode{code: 196}}]
             }
    end
  end

  describe "combine_colors_with_same_name_and_code" do
    test "combines colors with the same name and code and combines their sources" do
      colors =
        [
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :black,
            closest_named_hex: "FF00FF",
            distance_to_closest_named_hex: 0,
            source: [:color_data_api],
            exact_name_match?: true,
            renamed?: false,
            same_as: []
          },
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :white,
            closest_named_hex: nil,
            distance_to_closest_named_hex: nil,
            source: [:color_name_dot_com],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          }
        ]

      colors_collated = DataConverter.combine_colors_with_same_name_and_code(colors)

      assert colors_collated ==
               %Color{
                 name: :fuchsia,
                 ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
                 text_contrast_color: :black,
                 closest_named_hex: "FF00FF",
                 distance_to_closest_named_hex: 0,
                 source: [:color_data_api, :color_name_dot_com],
                 exact_name_match?: true,
                 renamed?: false,
                 same_as: []
               }
    end

    test "combines colors using the closest named hex with the shortest distance - comparison against nil" do
      colors =
        [
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :black,
            closest_named_hex: "FF00FF",
            distance_to_closest_named_hex: 60,
            source: [:color_data_api],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          },
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :white,
            closest_named_hex: nil,
            distance_to_closest_named_hex: nil,
            source: [:color_name_dot_com],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          }
        ]

      colors_collated = DataConverter.combine_colors_with_same_name_and_code(colors)

      assert colors_collated ==
               %Color{
                 name: :fuchsia,
                 ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
                 text_contrast_color: :black,
                 closest_named_hex: "FF00FF",
                 distance_to_closest_named_hex: 60,
                 source: [:color_data_api, :color_name_dot_com],
                 exact_name_match?: false,
                 renamed?: false,
                 same_as: []
               }
    end

    test "combines colors using the closest named hex with the shortest distance" do
      colors =
        [
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :black,
            closest_named_hex: "FF00FF",
            distance_to_closest_named_hex: 60,
            source: [:color_data_api],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          },
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :white,
            closest_named_hex: "FF00FD",
            distance_to_closest_named_hex: 120,
            source: [:color_name_dot_com],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          }
        ]

      colors_collated = DataConverter.combine_colors_with_same_name_and_code(colors)

      assert colors_collated ==
               %Color{
                 name: :fuchsia,
                 ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
                 text_contrast_color: :black,
                 closest_named_hex: "FF00FF",
                 distance_to_closest_named_hex: 60,
                 source: [:color_data_api, :color_name_dot_com],
                 exact_name_match?: false,
                 renamed?: false,
                 same_as: []
               }
    end

    test "raises an exception if the names do not match" do
      colors = [%Color{name: :fuchsia}, %Color{name: :not_fuchsia}]

      assert_raise(RuntimeError, "Colors must all have the same name; instead got :fuchsia, :not_fuchsia", fn ->
        DataConverter.combine_colors_with_same_name_and_code(colors)
      end)
    end

    test "raises an exception if the colors do not have the same ANSI code" do
      colors =
        [
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :black,
            closest_named_hex: "FF00FF",
            distance_to_closest_named_hex: 0,
            source: [:color_data_api],
            exact_name_match?: true,
            renamed?: false,
            same_as: []
          },
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 202, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :white,
            closest_named_hex: nil,
            distance_to_closest_named_hex: nil,
            source: [:color_name_dot_com],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          }
        ]

      assert_raise(RuntimeError, "Colors must all have the same ANSI color code; instead got 201, 202", fn ->
        DataConverter.combine_colors_with_same_name_and_code(colors)
      end)
    end
  end

  describe "combine_colors_with_same_name" do
    test "groups colors with the same name, combining their sources" do
      colors = %{
        purple_pizzazz: [
          %Color{
            name: :purple_pizzazz,
            ansi_color_code: %ANSIColorCode{code: 200, color_group: :pink, hex: "ff00d7", rgb: [255, 0, 215]},
            text_contrast_color: :black,
            closest_named_hex: "FF00CC",
            distance_to_closest_named_hex: 123,
            source: [:color_data_api],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          }
        ],
        shocking_pink: [
          %Color{
            name: :shocking_pink,
            ansi_color_code: %ANSIColorCode{code: 200, color_group: :pink, hex: "ff00d7", rgb: [255, 0, 215]},
            text_contrast_color: :white,
            closest_named_hex: nil,
            distance_to_closest_named_hex: nil,
            source: [:color_name_dot_com],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          }
        ],
        fuchsia: [
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :black,
            closest_named_hex: "FF00FF",
            distance_to_closest_named_hex: 0,
            source: [:color_data_api],
            exact_name_match?: true,
            renamed?: false,
            same_as: []
          },
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
            text_contrast_color: :white,
            closest_named_hex: nil,
            distance_to_closest_named_hex: nil,
            source: [:color_name_dot_com],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          },
          %Color{
            name: :fuchsia,
            ansi_color_code: %ANSIColorCode{code: 200, color_group: :pink, hex: "ff00fd", rgb: [255, 0, 255]},
            text_contrast_color: :white,
            closest_named_hex: nil,
            distance_to_closest_named_hex: nil,
            source: [:color_name_dot_com],
            exact_name_match?: false,
            renamed?: false,
            same_as: []
          }
        ]
      }

      colors_combined = DataConverter.combine_colors_with_same_name(colors)

      assert colors_combined == %{
               purple_pizzazz: [
                 %Color{
                   name: :purple_pizzazz,
                   ansi_color_code: %ANSIColorCode{code: 200, color_group: :pink, hex: "ff00d7", rgb: [255, 0, 215]},
                   text_contrast_color: :black,
                   closest_named_hex: "FF00CC",
                   distance_to_closest_named_hex: 123,
                   source: [:color_data_api],
                   exact_name_match?: false,
                   renamed?: false,
                   same_as: []
                 }
               ],
               shocking_pink: [
                 %Color{
                   name: :shocking_pink,
                   ansi_color_code: %ANSIColorCode{code: 200, color_group: :pink, hex: "ff00d7", rgb: [255, 0, 215]},
                   text_contrast_color: :white,
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: nil,
                   source: [:color_name_dot_com],
                   exact_name_match?: false,
                   renamed?: false,
                   same_as: []
                 }
               ],
               fuchsia: [
                 %Color{
                   name: :fuchsia,
                   ansi_color_code: %ANSIColorCode{code: 201, color_group: :pink, hex: "ff00ff", rgb: [255, 0, 255]},
                   text_contrast_color: :black,
                   closest_named_hex: "FF00FF",
                   distance_to_closest_named_hex: 0,
                   source: [:color_data_api, :color_name_dot_com],
                   exact_name_match?: true,
                   renamed?: false,
                   same_as: []
                 },
                 %Color{
                   name: :fuchsia,
                   ansi_color_code: %ANSIColorCode{code: 200, color_group: :pink, hex: "ff00fd", rgb: [255, 0, 255]},
                   text_contrast_color: :white,
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: nil,
                   source: [:color_name_dot_com],
                   exact_name_match?: false,
                   renamed?: false,
                   same_as: []
                 }
               ]
             }
    end
  end

  describe "group_by_name_frequency/1" do
    test "groups the colors so that the entries with the fewest colors go into the map first" do
      colors = %{
        black: [
          %Color{name: :black, ansi_color_code: %ANSIColorCode{hex: "000000", code: 0}, source: [:io_ansi]},
          %Color{name: :black, ansi_color_code: %ANSIColorCode{hex: "000000", code: 16}, source: [:color_name_dot_com]}
        ],
        black1: [
          %Color{name: :black1, ansi_color_code: %ANSIColorCode{hex: "000000", code: 0}, source: [:colorhexa]}
        ]
      }

      color_map = DataConverter.group_by_name_frequency(colors)

      assert color_map == %{
               black: %Color{
                 name: :black,
                 ansi_color_code: %ANSIColorCode{hex: "000000", code: 16},
                 source: [:color_name_dot_com]
               },
               black1: %Color{
                 name: :black1,
                 ansi_color_code: %ANSIColorCode{hex: "000000", code: 0},
                 source: [:colorhexa]
               }
             }
    end
  end

  describe "codes_by_frequency_count/1" do
    test "sums the number of references to each ansi color code" do
      colors = %{
        black: [
          %Color{name: :black, ansi_color_code: %ANSIColorCode{hex: "000000", code: 0}, source: [:io_ansi]},
          %Color{name: :black, ansi_color_code: %ANSIColorCode{hex: "000000", code: 16}, source: [:color_name_dot_com]}
        ],
        black1: [
          %Color{name: :black1, ansi_color_code: %ANSIColorCode{hex: "000000", code: 0}, source: [:colorhexa]}
        ]
      }

      codes_by_frequency = DataConverter.codes_by_frequency_count(colors)

      assert codes_by_frequency == %{
               %ANSIColorCode{hex: "000000", code: 0} => 2,
               %ANSIColorCode{hex: "000000", code: 16} => 1
             }
    end
  end

  describe "do I even need group_by_name_frequency" do
    test "see how many for each color name" do
      combined_colors_collated = ColorPalette.combined_colors_collated()
      assert Map.keys(combined_colors_collated) |> length() == 502

      with_more_than_one_color =
        combined_colors_collated
        |> Enum.filter(fn {_color_name, colors} -> length(colors) > 1 end)
        |> Enum.into(%{})

      assert Map.keys(with_more_than_one_color) |> length() == 124

      with_more_than_two_colors =
        combined_colors_collated
        |> Enum.filter(fn {_color_name, colors} -> length(colors) > 2 end)
        |> Enum.into(%{})

      assert Map.keys(with_more_than_two_colors) |> length() == 61
    end
  end

  describe "codes_to_names/1" do
    test "returns a map from the code to the names for that code" do
      collated = ColorPalette.combined_colors_collated()
      counts = DataConverter.codes_to_names(collated)
      code = %ColorPalette.ANSIColorCode{code: 156, color_group: :green, hex: "afff87", rgb: [175, 255, 135]}
      assert Map.get(counts, code) |> Enum.sort() == [:mint_green, :very_light_green]
    end
  end

  describe "codes_to_name_counts/1" do
    test "returns a map from the code to the count of the names" do
      collated = ColorPalette.combined_colors_collated()
      counts = DataConverter.codes_to_name_counts(collated)
      code = %ColorPalette.ANSIColorCode{code: 156, color_group: :green, hex: "afff87", rgb: [175, 255, 135]}
      assert Map.get(counts, code) == 2
    end
  end

  describe "name_stats" do
    test "maps from names to codes, sources, and frequencies" do
      collated = ColorPalette.combined_colors_collated()
      stats = DataConverter.compute_stats(collated)

      yellow = stats.yellow

      assert yellow == %{
               226 => %{
                 sources: [:color_data_api, :color_name_dot_com, :colorhexa],
                 other_names: []
               },
               11 => %{
                 sources: [:color_data_api, :color_name_dot_com, :colorhexa],
                 other_names: [:light_yellow]
               },
               3 => %{
                 sources: [:io_ansi],
                 other_names: [:olive]
               }
             }
    end
  end
end
