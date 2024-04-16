defmodule ColorPalette.PrecompileHook do
  @moduledoc false

  import ColorPalette.Color

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.DataConverter

  defmacro __before_compile__(_env) do
    quote do
      @io_ansi_color_names __DIR__
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

      @color_data_api_colors @color_data_api_raw_data
                             |> DataConverter.convert_color_data_api_raw_data(@ansi_color_codes)

      @color_name_dot_com_colors @color_name_dot_com_raw_data
                                 |> DataConverter.convert_color_name_dot_com_raw_data(@ansi_color_codes)

      @io_ansi_colors @io_ansi_color_names
                      |> DataConverter.convert_ansi_colors_to_colors(@ansi_color_codes)

      @all_colors DataConverter.combine_colors(
                    @io_ansi_colors,
                    @color_data_api_colors,
                    @color_name_dot_com_colors
                  )

      @colors_grouped_by_name @all_colors |> DataConverter.group_colors_by_name()

      @color_names_to_colors @colors_grouped_by_name
                             |> List.flatten()
                             |> DataConverter.color_names_to_colors()

      @unique_color_names_to_colors @color_names_to_colors
                                    |> Enum.map(fn {color_name, colors} ->
                                      {color_name, List.first(colors)}
                                    end)
                                    |> Enum.into(%{})

      @ansi_color_codes_without_names @unique_color_names_to_colors |> DataConverter.unnamed_ansi_color_codes()
      @generated_names_for_unnamed_colors DataConverter.create_names_for_missing_colors(
                                            @all_colors,
                                            @ansi_color_codes_without_names
                                          )
      @colors @unique_color_names_to_colors |> Map.merge(@generated_names_for_unnamed_colors)

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
      def color_name_dot_com_raw_data, do: @color_name_dot_com_raw_data
      def ansi_color_codes, do: @ansi_color_codes
      def color_groups, do: @color_groups
      def io_ansi_color_names, do: @io_ansi_color_names

      def io_ansi_colors, do: @io_ansi_colors
      def color_name_dot_com_colors, do: @color_name_dot_com_colors
      def color_data_api_colors, do: @color_data_api_colors
      def all_colors, do: @all_colors

      def color_names_to_colors, do: @color_names_to_colors
      def colors_grouped_by_name, do: @colors_grouped_by_name
      def unique_color_names_to_colors, do: @unique_color_names_to_colors
      def ansi_color_codes_without_names, do: @ansi_color_codes_without_names

      def generated_names_for_unnamed_colors, do: @generated_names_for_unnamed_colors

      @doc """
      A map between the color name and the `ColorPalette.Color` struct
      """
      def colors, do: @colors
    end
  end
end
