defmodule ColorPalette.PrecompileHook do
  @moduledoc false

  import ColorPalette.Color

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.DataConverter

  defmacro __before_compile__(_env) do
    quote do
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

      @colors DataConverter.convert_color_data_api_raw_data(@color_data_api_raw_data, @ansi_color_codes)
              |> Map.merge(DataConverter.convert_color_name_dot_com_raw_data(@color_name_dot_com_raw_data, @ansi_color_codes))
              |> Map.merge(DataConverter.convert_ansi_colors_to_color_names(@io_ansi_colors, @ansi_color_codes))
              |> DataConverter.find_duplicates()
              |> DataConverter.clear_out_color_data()

      @colors
      |> Enum.each(fn {color_name, color} ->
        hex = color.ansi_color_code.hex
        code = color.ansi_color_code.code
        text_contrast_color = color.text_contrast_color

        if color.source == :io_ansi do
          delegate_to_io_ansi(color_name, hex, text_contrast_color, code)
          background_color_name = String.to_atom("#{color_name}_background")
          delegate_to_io_ansi(background_color_name, hex, text_contrast_color, code + 10)
        else
          def_color(color_name, hex, text_contrast_color, color.same_as, [code])
        end
      end)

      def ansi_color_codes, do: @ansi_color_codes
      def color_data_api_raw_data, do: @color_data_api_raw_data
      def color_groups_to_ansi_color_codes, do: @color_groups_to_ansi_color_codes
      def color_groups, do: @color_groups
      def color_name_dot_com_raw_data, do: @color_name_dot_com_raw_data
      def colors, do: @colors
      def io_ansi_colors, do: @io_ansi_colors
    end
  end
end
