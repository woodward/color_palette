defmodule ColorPalette.PrecompileHook do
  @moduledoc false

  import ColorPalette.Color

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.DataConverter

  defmacro __before_compile__(_env) do
    quote do
      # --------------------------------------------------------------------------------------------
      # Raw Data:

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

      # ------------------------

      @color_data_api_raw_data __DIR__
                               |> Path.join("color_palette/data/color_data_api_colors.json")
                               |> File.read!()
                               |> Jason.decode!(keys: :atoms)

      @color_name_dot_com_raw_data __DIR__
                                   |> Path.join("color_palette/data/color-name.com_colors.json")
                                   |> File.read!()
                                   |> Jason.decode!(keys: :atoms)

      @colorhexa_raw_data __DIR__
                          |> Path.join("color_palette/data/colorhexa.com_colors.json")
                          |> File.read!()
                          |> Jason.decode!(keys: :atoms)

      # --------------------------------------------------------------------------------------------
      # Raw Data Converted to `ColorPalette.Color` structs:

      @color_data_api_colors @color_data_api_raw_data
                             |> DataConverter.convert_raw_color_data_api_to_colors(@ansi_color_codes)

      @color_name_dot_com_colors @color_name_dot_com_raw_data
                                 |> DataConverter.convert_raw_color_data_to_colors(@ansi_color_codes, :color_name_dot_com)

      @colorhexa_colors @colorhexa_raw_data
                        |> DataConverter.convert_raw_color_data_to_colors(@ansi_color_codes, :colorhexa)

      @io_ansi_colors @io_ansi_color_names
                      |> DataConverter.convert_ansi_colors_to_colors(@ansi_color_codes)

      # --------------------------------------------------------------------------------------------
      # Tranformation & Grouping of the Data:

      @colors_initial DataConverter.multi_zip([
                        @io_ansi_colors ++ List.duplicate(nil, 256 - 16),
                        @color_data_api_colors,
                        @color_name_dot_com_colors,
                        @colorhexa_colors
                      ])

      # ----------------------
      # Perhaps get rid of the intermediate variable @colors_initial_ordered_by_code
      @colors_initial_ordered_by_code @colors_initial

      @colors_ordered_by_code @colors_initial_ordered_by_code
                              |> DataConverter.collate_colors_with_same_name_for_code()
                              |> DataConverter.annotate_same_as_field()

      @colors_by_name @colors_ordered_by_code
                      |> DataConverter.group_by_name_frequency()
                      |> DataConverter.purge_orphaned_same_as_entries()

      @ansi_color_codes_missing_names @colors_by_name |> DataConverter.unnamed_ansi_color_codes()

      @generated_names_for_unnamed_colors DataConverter.create_names_for_missing_colors(
                                            @colors_initial_ordered_by_code,
                                            @ansi_color_codes_missing_names
                                          )

      # -------------------------------
      # The main colors data structure:
      @colors @colors_by_name |> Map.merge(@generated_names_for_unnamed_colors)

      # --------------------------------------------------------------------------------------------
      # Old version of generating the color data (kept for now for reference):
      # @old_all_colors @colors_initial |> DataConverter.annotate_same_as_field()

      # @old_color_names_to_colors @old_all_colors
      #                            |> List.flatten()
      #                            |> DataConverter.color_names_to_colors()

      # @old_unique_color_names_to_colors @old_color_names_to_colors
      #                                   |> Enum.map(fn {color_name, colors} ->
      #                                     {color_name, List.first(colors)}
      #                                   end)
      #                                   |> Enum.into(%{})

      # @old_ansi_color_codes_missing_names @old_unique_color_names_to_colors |> DataConverter.unnamed_ansi_color_codes()
      # @old_generated_names_for_unnamed_colors DataConverter.create_names_for_missing_colors(
      #                                           @colors_initial,
      #                                           @old_ansi_color_codes_missing_names
      #                                         )

      # # -------------------------------
      # # The main colors data structure:
      # @old_colors @old_unique_color_names_to_colors |> Map.merge(@old_generated_names_for_unnamed_colors)

      # --------------------------------------------------------------------------------------------
      # Generate `ColorPalette` functions for the colors:

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

      # --------------------------------------------------------------------------------------------
      # Accessors
      # ---------

      # Raw Data:
      def color_groups_to_ansi_color_codes, do: @color_groups_to_ansi_color_codes
      def color_data_api_raw_data, do: @color_data_api_raw_data
      def color_name_dot_com_raw_data, do: @color_name_dot_com_raw_data
      def colorhexa_raw_data, do: @colorhexa_raw_data
      def ansi_color_codes, do: @ansi_color_codes
      def color_groups, do: @color_groups
      def io_ansi_color_names, do: @io_ansi_color_names

      # ---------------------------------------------------
      # Raw Data converetd to `ColorPalette.Color` structs:

      def io_ansi_colors, do: @io_ansi_colors
      def color_name_dot_com_colors, do: @color_name_dot_com_colors
      def color_data_api_colors, do: @color_data_api_colors
      def colorhexa_colors, do: @colorhexa_colors
      def colors_initial, do: @colors_initial

      # ---------------------------
      # Transformed & Grouped Data:

      # def old_all_colors, do: @old_all_colors
      # def old_color_names_to_colors, do: @old_color_names_to_colors
      # def old_unique_color_names_to_colors, do: @old_unique_color_names_to_colors
      # def old_ansi_color_codes_missing_names, do: @old_ansi_color_codes_missing_names
      # def old_generated_names_for_unnamed_colors, do: @old_generated_names_for_unnamed_colors
      # def old_colors, do: @old_colors

      # -----------------------------
      # Transformed & Grouped Data:

      def colors_ordered_by_code, do: @colors_ordered_by_code
      def colors_by_name, do: @colors_by_name
      def ansi_color_codes_missing_names, do: @ansi_color_codes_missing_names
      def generated_names_for_unnamed_colors, do: @generated_names_for_unnamed_colors

      # -------------------------------
      @doc """
      The main colors data structure.  A map between the color name and the `ColorPalette.Color` struct
      """
      def colors, do: @colors
    end
  end
end
