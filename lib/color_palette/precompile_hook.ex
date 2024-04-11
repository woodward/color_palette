defmodule ColorPalette.PrecompileHook do
  @moduledoc false

  import ColorPalette.Color
  alias ColorPalette.ANSIColorCode

  defmacro __before_compile__(_env) do
    quote do
      alias ColorPalette.Utils

      @io_ansi_colors %{
        black: %{code: 0, text_contrast_color: :white},
        red: %{code: 1, text_contrast_color: :white},
        green: %{code: 2, text_contrast_color: :white},
        yellow: %{code: 3, text_contrast_color: :white},
        blue: %{code: 4, text_contrast_color: :white},
        magenta: %{code: 5, text_contrast_color: :white},
        cyan: %{code: 6, text_contrast_color: :white},
        white: %{code: 7, text_contrast_color: :black},
        #
        light_black: %{code: 8, text_contrast_color: :white},
        light_red: %{code: 9, text_contrast_color: :white},
        light_green: %{code: 10, text_contrast_color: :white},
        light_yellow: %{code: 11, text_contrast_color: :white},
        light_blue: %{code: 12, text_contrast_color: :white},
        light_magenta: %{code: 13, text_contrast_color: :white},
        light_cyan: %{code: 14, text_contrast_color: :white},
        light_white: %{code: 15, text_contrast_color: :black}
      }

      @color_groups [
        :blue,
        :brown,
        :cyan,
        :gray_and_black,
        :green,
        :orange,
        :pink,
        :purple_violet_and_magenta,
        :red,
        :white,
        :yellow
      ]

      @ansi_color_codes_by_group __DIR__
                                 |> Path.join("color_palette/ansi_color_codes_by_group.json")
                                 |> Utils.read_json_file!()
                                 |> Enum.map(&if &1.color_group, do: String.to_atom(&1.color_group), else: nil)

      @ansi_color_codes __DIR__
                        |> Path.join("color_palette/ansi_color_codes.json")
                        |> Utils.read_json_file!()
                        |> Enum.zip(@ansi_color_codes_by_group)
                        |> Enum.map(fn {ansi_color_code, color_group} ->
                          Map.put(ansi_color_code, :color_group, color_group)
                        end)
                        |> Enum.map(&Map.merge(%ANSIColorCode{}, &1))

      @color_groups_to_ansi_color_codes @ansi_color_codes
                                        |> ColorPalette.ColorNames.color_groups_to_ansi_color_codes(@color_groups)

      @color_data_api_raw_data __DIR__
                               |> Path.join("color_palette/color_data_api_colors.json")
                               |> Utils.read_json_file!()

      @color_name_dot_com_raw_data __DIR__
                                   |> Path.join("color_palette/color-name.com_colors.json")
                                   |> Utils.read_json_file!()

      @colors ColorPalette.ColorNames.convert_color_data_api_raw_data(@color_data_api_raw_data, @ansi_color_codes)
              |> Map.merge(
                ColorPalette.ColorNames.convert_color_name_dot_com_raw_data(@color_name_dot_com_raw_data, @ansi_color_codes)
              )
              |> Map.merge(ColorPalette.ColorNames.convert_ansi_colors_to_color_names(@io_ansi_colors, @ansi_color_codes))
              |> ColorPalette.ColorNames.find_duplicates()
              |> ColorPalette.ColorNames.clear_out_color_data()

      @colors
      |> Enum.each(fn {color_name, color} ->
        if color.source == :io_ansi do
          delegate_to_io_ansi(color_name)
          delegate_to_io_ansi(String.to_atom("#{color_name}_background"))
        else
          def_color(color_name, [color.ansi_color_code.code])
          background_name = "#{color_name}_background" |> String.to_atom()
          def_background_color(background_name, [color.ansi_color_code.code])
        end
      end)

      def ansi_color_codes, do: @ansi_color_codes
      def color_data_api_raw_data, do: @color_data_api_raw_data
      def color_name_dot_com_raw_data, do: @color_name_dot_com_raw_data
      def colors, do: @colors
      def io_ansi_colors, do: @io_ansi_colors
      def color_groups_to_ansi_color_codes, do: @color_groups_to_ansi_color_codes
      def color_groups, do: @color_groups
    end
  end
end
