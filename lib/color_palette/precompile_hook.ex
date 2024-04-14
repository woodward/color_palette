defmodule ColorPalette.PrecompileHook do
  @moduledoc false

  import ColorPalette.Color

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.DataConverter

  defmacro __before_compile__(_env) do
    quote do
      @io_ansi_color_names %{
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
        light_green: %{code: 10, text_contrast_color: :black},
        light_yellow: %{code: 11, text_contrast_color: :black},
        light_blue: %{code: 12, text_contrast_color: :white},
        light_magenta: %{code: 13, text_contrast_color: :white},
        light_cyan: %{code: 14, text_contrast_color: :black},
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
                                 |> Path.join("color_palette/data/ansi_color_codes_by_group.json")
                                 |> File.read!()
                                 |> Jason.decode!(keys: :atoms)
                                 |> Enum.map(&if &1.color_group, do: String.to_atom(&1.color_group), else: nil)

      @ansi_color_codes __DIR__
                        |> Path.join("color_palette/data/ansi_color_codes.json")
                        |> File.read!()
                        |> Jason.decode!(keys: :atoms)
                        |> Enum.zip(@ansi_color_codes_by_group)
                        |> Enum.map(fn {ansi_color_code, color_group} ->
                          Map.put(ansi_color_code, :color_group, color_group)
                        end)
                        |> Enum.map(&Map.merge(%ANSIColorCode{}, &1))

      @color_groups_to_ansi_color_codes @ansi_color_codes
                                        |> DataConverter.color_groups_to_ansi_color_codes(@color_groups)

      @color_data_api_raw_data __DIR__
                               |> Path.join("color_palette/data/color_data_api_colors.json")
                               |> File.read!()
                               |> Jason.decode!(keys: :atoms)

      @color_name_dot_com_raw_data __DIR__
                                   |> Path.join("color_palette/data/color-name.com_colors.json")
                                   |> File.read!()
                                   |> Jason.decode!(keys: :atoms)

      @color_data_api_colors @color_data_api_raw_data
                             |> DataConverter.convert_color_data_api_raw_data(@ansi_color_codes)

      @new_color_data_api_colors @color_data_api_raw_data
                                 |> DataConverter.new_convert_color_data_api_raw_data(@ansi_color_codes)

      # Data good above here
      # --------------------

      @color_name_dot_com_colors @color_name_dot_com_raw_data
                                 |> DataConverter.convert_color_name_dot_com_raw_data(@ansi_color_codes)

      @new_color_name_dot_com_colors @color_name_dot_com_raw_data
                                     |> DataConverter.new_convert_color_name_dot_com_raw_data(@ansi_color_codes)

      @io_ansi_colors @io_ansi_color_names
                      |> DataConverter.convert_ansi_colors_to_color_names(@ansi_color_codes)

      @colors_untransformed @color_data_api_colors
                            |> Map.merge(@color_name_dot_com_colors)
                            |> Map.merge(@io_ansi_colors)

      @colors @colors_untransformed
              |> DataConverter.backfill_missing_names(@ansi_color_codes, @color_data_api_raw_data)
              |> DataConverter.find_duplicates()
              |> DataConverter.clear_out_color_data_deprecated()

      @colors
      |> Enum.each(fn {color_name, color} ->
        hex = color.ansi_color_code.hex
        color_group = color.ansi_color_code.color_group
        code = color.ansi_color_code.code
        text_contrast_color = color.text_contrast_color

        if color.source == :io_ansi do
          delegate_to_io_ansi(color_name, hex, text_contrast_color, color_group, code)
        else
          def_color(color_name, hex, text_contrast_color, color.same_as, color.source, color_group, code)
        end
      end)

      def ansi_color_codes, do: @ansi_color_codes
      def color_data_api_raw_data, do: @color_data_api_raw_data
      def color_groups_to_ansi_color_codes, do: @color_groups_to_ansi_color_codes
      def color_groups, do: @color_groups
      def color_name_dot_com_raw_data, do: @color_name_dot_com_raw_data
      def colors, do: @colors
      def io_ansi_color_names, do: @io_ansi_color_names
      def color_data_api_colors, do: @color_data_api_colors
      def color_data_api_raw_data, do: @color_data_api_raw_data
      def colors_untransformed, do: @colors_untransformed
    end
  end
end
