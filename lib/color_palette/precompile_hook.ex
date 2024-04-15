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

      @new_io_ansi_color_names __DIR__
                               |> Path.join("color_palette/data/ansi_color_names.json")
                               |> File.read!()
                               |> Jason.decode!(keys: :atoms)
                               |> Enum.map(
                                 &%{
                                   &1
                                   | name: String.to_atom(&1.name),
                                     text_contrast_color: String.to_atom(&1.text_contrast_color)
                                 }
                               )

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

      @new_color_data_api_colors @color_data_api_raw_data
                                 |> DataConverter.new_convert_color_data_api_raw_data(@ansi_color_codes)

      @new_color_name_dot_com_colors @color_name_dot_com_raw_data
                                     |> DataConverter.new_convert_color_name_dot_com_raw_data(@ansi_color_codes)

      @new_io_ansi_colors @new_io_ansi_color_names
                          |> DataConverter.new_convert_ansi_colors_to_color_names(@ansi_color_codes)

      @new_all_colors DataConverter.combine_colors(
                        @new_io_ansi_colors,
                        @new_color_data_api_colors,
                        @new_color_name_dot_com_colors
                      )

      @new_colors_grouped_by_name @new_all_colors |> DataConverter.new_group_colors_by_name()

      @new_color_names_to_colors @new_colors_grouped_by_name
                                 |> List.flatten()
                                 |> DataConverter.new_color_names_to_colors()

      @new_unique_color_names_to_colors @new_color_names_to_colors
                                        |> Enum.map(fn {color_name, colors} ->
                                          {color_name, List.first(colors)}
                                        end)
                                        |> Enum.into(%{})

      @missing_colors @new_unique_color_names_to_colors |> DataConverter.new_unnamed_ansi_color_codes()
      @new_colors_missing_names DataConverter.create_names_for_missing_colors(@new_all_colors, @missing_colors)
      @colors @new_unique_color_names_to_colors |> Map.merge(@new_colors_missing_names)

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

      def color_groups_to_ansi_color_codes, do: @color_groups_to_ansi_color_codes
      def color_data_api_raw_data, do: @color_data_api_raw_data
      def io_ansi_color_names, do: @io_ansi_color_names

      def color_groups, do: @color_groups
      def ansi_color_codes, do: @ansi_color_codes
      def color_data_api_raw_data, do: @color_data_api_raw_data
      def color_name_dot_com_raw_data, do: @color_name_dot_com_raw_data
      def new_io_ansi_colors, do: @new_io_ansi_colors
      def new_io_ansi_color_names, do: @new_io_ansi_color_names
      def new_color_name_dot_com_colors, do: @new_color_name_dot_com_colors
      def new_color_data_api_colors, do: @new_color_data_api_colors
      def new_all_colors, do: @new_all_colors
      def new_color_names_to_colors, do: @new_color_names_to_colors
      def new_colors_grouped_by_name, do: @new_colors_grouped_by_name
      def new_unique_color_names_to_colors, do: @new_unique_color_names_to_colors

      def missing_colors, do: @missing_colors
      def new_colors_missing_names, do: @new_colors_missing_names
      def colors, do: @colors
    end
  end
end
