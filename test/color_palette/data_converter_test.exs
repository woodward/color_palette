defmodule ColorPalette.DataConverterTest do
  @moduledoc false
  use ExUnit.Case

  alias ColorPalette.DataConverter
  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color

  describe "convert_color_data_api_raw_data" do
    test "adds color names and text_contrast_color to ansi color codes" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.color_data_api_raw_data()

      colors = DataConverter.convert_color_data_api_raw_data(color_data, color_codes)
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
                 same_as: []
               }
             ]
    end
  end

  describe "convert_colorhexa_raw_data" do
    test "adds color names and text_contrast_color to ansi color codes" do
      color_codes = ColorPalette.ansi_color_codes()
      color_data = ColorPalette.colorhexa_raw_data()

      colors = DataConverter.convert_colorhexa_raw_data(color_data, color_codes)
      assert length(colors) == 256

      # ------------------------

      black = colors |> List.first()

      assert black.name == :black
      assert black.ansi_color_code == %ANSIColorCode{code: 0, hex: "000000", color_group: :gray_and_black, rgb: [0, 0, 0]}
      assert black.text_contrast_color == :black
      assert black.source == [:colorhexa]
      assert black.closest_named_hex == nil
      assert black.distance_to_closest_named_hex == nil
      assert black.exact_name_match? == false

      # ------------------------

      pure_violet = colors |> Enum.at(129)

      assert pure_violet.name == :pure_violet

      assert pure_violet.ansi_color_code == %ANSIColorCode{
               code: 129,
               color_group: :purple_violet_and_magenta,
               hex: "af00ff",
               rgb: [175, 0, 255]
             }

      assert pure_violet.text_contrast_color == :black
      assert pure_violet.source == [:colorhexa]
      assert pure_violet.closest_named_hex == nil
      assert pure_violet.distance_to_closest_named_hex == nil
      assert pure_violet.exact_name_match? == false

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
                 exact_name_match?: false,
                 same_as: []
               },
               %Color{
                 name: :lime_green,
                 ansi_color_code: %ANSIColorCode{code: 158, color_group: :cyan, hex: "afffd7", rgb: [175, 255, 215]},
                 text_contrast_color: :black,
                 closest_named_hex: nil,
                 distance_to_closest_named_hex: nil,
                 source: [:colorhexa],
                 exact_name_match?: false,
                 same_as: []
               }
             ]
    end
  end

  describe "group_colors_by_name" do
    test "groups colors by name" do
      colors = [
        [
          %ColorPalette.Color{
            name: :black,
            ansi_color_code: %ColorPalette.ANSIColorCode{code: 0, hex: "000000", rgb: [0, 0, 0], color_group: :gray_and_black},
            text_contrast_color: :white,
            closest_named_hex: nil,
            distance_to_closest_named_hex: 0,
            source: [:io_ansi],
            exact_name_match?: true,
            same_as: []
          },
          %ColorPalette.Color{
            name: :black,
            ansi_color_code: %ColorPalette.ANSIColorCode{code: 0, hex: "000000", rgb: [0, 0, 0], color_group: :gray_and_black},
            text_contrast_color: :white,
            closest_named_hex: "000000",
            distance_to_closest_named_hex: 0,
            source: [:color_data_api],
            exact_name_match?: true,
            same_as: []
          },
          %ColorPalette.Color{
            name: :black,
            ansi_color_code: %ColorPalette.ANSIColorCode{code: 0, hex: "000000", rgb: [0, 0, 0], color_group: :gray_and_black},
            text_contrast_color: :white,
            closest_named_hex: nil,
            distance_to_closest_named_hex: nil,
            source: [:color_name_dot_com],
            exact_name_match?: false,
            same_as: []
          }
        ],
        [
          %ColorPalette.Color{
            name: :purple_pizzazz,
            ansi_color_code: %ColorPalette.ANSIColorCode{code: 200, hex: "ff00d7", rgb: [255, 0, 215], color_group: :pink},
            text_contrast_color: :black,
            closest_named_hex: "FF00CC",
            distance_to_closest_named_hex: 123,
            source: [:color_data_api],
            exact_name_match?: false,
            same_as: []
          },
          %ColorPalette.Color{
            name: :shocking_pink,
            ansi_color_code: %ColorPalette.ANSIColorCode{code: 200, hex: "ff00d7", rgb: [255, 0, 215], color_group: :pink},
            text_contrast_color: :white,
            closest_named_hex: nil,
            distance_to_closest_named_hex: nil,
            source: [:color_name_dot_com],
            exact_name_match?: false,
            same_as: []
          }
        ]
      ]

      grouped = DataConverter.group_colors_by_name(colors)

      assert grouped == [
               [
                 %ColorPalette.Color{
                   name: :black,
                   ansi_color_code: %ColorPalette.ANSIColorCode{
                     code: 0,
                     hex: "000000",
                     rgb: [0, 0, 0],
                     color_group: :gray_and_black
                   },
                   text_contrast_color: :white,
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: 0,
                   source: [:io_ansi, :color_data_api, :color_name_dot_com],
                   exact_name_match?: true,
                   same_as: []
                 }
               ],
               [
                 %ColorPalette.Color{
                   name: :purple_pizzazz,
                   ansi_color_code: %ColorPalette.ANSIColorCode{code: 200, hex: "ff00d7", rgb: [255, 0, 215], color_group: :pink},
                   text_contrast_color: :black,
                   closest_named_hex: "FF00CC",
                   distance_to_closest_named_hex: 123,
                   source: [:color_data_api],
                   exact_name_match?: false,
                   same_as: [:shocking_pink]
                 },
                 %ColorPalette.Color{
                   name: :shocking_pink,
                   ansi_color_code: %ColorPalette.ANSIColorCode{code: 200, hex: "ff00d7", rgb: [255, 0, 215], color_group: :pink},
                   text_contrast_color: :white,
                   closest_named_hex: nil,
                   distance_to_closest_named_hex: nil,
                   source: [:color_name_dot_com],
                   exact_name_match?: false,
                   same_as: [:purple_pizzazz]
                 }
               ]
             ]
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
      assert DataConverter.color_name_to_atom("Black") == :black
    end

    test "snake cases multi-word colors" do
      assert DataConverter.color_name_to_atom("Rose of Sharon") == :rose_of_sharon
    end

    test "works for colors with apostrophes" do
      assert DataConverter.color_name_to_atom("Screamin' Green") == :screamin_green
    end

    test "works for colors with dashes" do
      assert DataConverter.color_name_to_atom("Yellow-Green") == :yellow_green
    end

    test "returns two colors if a slash" do
      assert DataConverter.color_name_to_atom("Magenta / Fuchsia") == [:magenta, :fuchsia]
    end

    test "gets rid of content in parens" do
      assert DataConverter.color_name_to_atom("Gold (Web)") == :gold
    end

    test "drops the é on :tenné" do
      assert DataConverter.color_name_to_atom("Tenné") == :tenn
    end

    test "drops the '(mostly black)' phrase on colorhexa names" do
      assert DataConverter.color_name_to_atom("Very dark gray (mostly black)") == :very_dark_gray
    end

    test "drops the '(or mostly pure)' phrase on colorhexa names" do
      assert DataConverter.color_name_to_atom("Pure (or mostly pure) orange") == :pure_orange
    end

    test "changes the '[Pink tone]' phrase on colorhexa names" do
      assert DataConverter.color_name_to_atom("Very pale red [Pink tone]") == :very_pale_red_pink_tone
    end

    test "changes the '[Olive tone]' phrase on colorhexa names" do
      assert DataConverter.color_name_to_atom("Dark yellow [Olive tone]") == :dark_yellow_olive_tone
    end

    test "splits colorhexa names with a dash" do
      assert DataConverter.color_name_to_atom("Very light cyan - lime green") == [:very_light_cyan, :lime_green]
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

  describe "convert_color_name_dot_com_raw_data" do
    test "converts the color-name.com raw data into a list of Colors" do
      ansi_codes = ColorPalette.ansi_color_codes()
      color_name_dot_com_raw_data = ColorPalette.color_name_dot_com_raw_data()

      colors = DataConverter.convert_color_name_dot_com_raw_data(color_name_dot_com_raw_data, ansi_codes)

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

  describe "convert_ansi_colors_to_colors" do
    test "works" do
      ansi_codes = ColorPalette.ansi_color_codes()
      ansi_colors = ColorPalette.io_ansi_color_names()

      colors = DataConverter.convert_ansi_colors_to_colors(ansi_colors, ansi_codes)

      assert length(colors) == 16
      black = colors |> List.first()

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

  describe "multi_zip" do
    test "combines the lists" do
      list1 = ["a", "b", "c"]
      list2 = ["dog", "cat", "squirrel"]
      list3 = ["apple", "orange", "banana"]

      combined = DataConverter.multi_zip([list1, list2, list3])

      assert combined == [
               ["a", "dog", "apple"],
               ["b", "cat", "orange"],
               ["c", "squirrel", "banana"]
             ]
    end

    test "filters out nil values" do
      list1 = ["a", "b", nil]
      list2 = ["dog", nil, "squirrel"]
      list3 = [nil, "orange", "banana"]

      combined = DataConverter.multi_zip([list1, list2, list3])

      assert combined == [
               ["a", "dog"],
               ["b", "orange"],
               ["squirrel", "banana"]
             ]
    end

    test "combines the lists, even if the elements are themselves list" do
      list1 = ["a", ["b", "c"], ["d", "e"]]
      list2 = ["dog", "cat", "squirrel"]
      list3 = ["apple", ["orange", "tangerine"], "banana"]

      combined = DataConverter.multi_zip([list1, list2, list3])

      assert combined == [
               ["a", "dog", "apple"],
               ["b", "c", "cat", "orange", "tangerine"],
               ["d", "e", "squirrel", "banana"]
             ]
    end

    test "raises an exception if the lists are not of the same length" do
      list1 = ["a", "b", "c"]
      list2 = ["dog", "cat"]
      list3 = ["apple", "orange", "banana"]

      assert_raise RuntimeError, fn ->
        DataConverter.multi_zip([list1, list2, list3])
      end
    end
  end

  describe "color_names_to_colors" do
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
          same_as: []
        }
      ]

      grouped = DataConverter.color_names_to_colors(colors)

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
                   same_as: []
                 },
                 %ColorPalette.Color{
                   ansi_color_code: %ColorPalette.ANSIColorCode{code: 6, color_group: :cyan, hex: "008080", rgb: [0, 128, 128]},
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
                   same_as: []
                 }
               ]
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

  describe "unnamed_ansi_color_codes" do
    test "returns a list of IO ansi color codes without a name" do
      colors = ColorPalette.unique_color_names_to_colors()

      color_codes_with_no_names = DataConverter.unnamed_ansi_color_codes(colors)

      assert length(color_codes_with_no_names) == 33

      first_five = color_codes_with_no_names |> Enum.take(5)
      last_five = color_codes_with_no_names |> Enum.reverse() |> Enum.take(5) |> Enum.sort()

      assert first_five == [0, 1, 3, 4, 6]
      assert last_five == [163, 171, 234, 244, 246]
    end
  end

  describe "create_names_for_missing_colors/2" do
    test "creates some fake color names for colors which are missing names" do
      all_colors = ColorPalette.all_colors()
      missing_names = [22, 33]
      new_names = DataConverter.create_names_for_missing_colors(all_colors, missing_names)

      assert new_names == %{
               azure_radiance_0087ff: %Color{
                 name: :azure_radiance_0087ff,
                 ansi_color_code: %ANSIColorCode{code: 33, hex: "0087ff", rgb: [0, 135, 255], color_group: :blue},
                 text_contrast_color: :black,
                 closest_named_hex: "007FFF",
                 distance_to_closest_named_hex: 66,
                 source: [:color_data_api],
                 exact_name_match?: false,
                 same_as: [],
                 renamed?: true
               },
               camarone_005f00: %Color{
                 name: :camarone_005f00,
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
end
