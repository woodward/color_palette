defmodule ColorPalette.PrecompileHook do
  @moduledoc false

  import ColorPalette.Color

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.DataConverter
  alias ColorPalette.ColorGroup

  defmacro __before_compile__(_env) do
    quote do
      # --------------------------------------------------------------------------------------------
      # Raw Data:

      @io_ansi_color_names __DIR__
                           |> Path.join("color_palette/data/ansi_color_names.json")
                           |> File.read!()
                           |> Jason.decode!(keys: :atoms)
                           |> Enum.map(&(&1 |> Map.merge(%{exact_name_match?: true, distance_to_closest_named_hex: 0})))

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
                                        |> DataConverter.color_groups_to_ansi_color_codes(ColorGroup.color_groups())

      # ------------------------

      @raw_color_data_api_data __DIR__
                               |> Path.join("color_palette/data/color_data_api_colors.json")
                               |> File.read!()
                               |> Jason.decode!(keys: :atoms)
                               |> Enum.map(&DataConverter.normalize_data(&1))

      @raw_color_name_dot_com_data __DIR__
                                   |> Path.join("color_palette/data/color-name.com_colors.json")
                                   |> File.read!()
                                   |> Jason.decode!(keys: :atoms)

      @raw_colorhexa_data __DIR__
                          |> Path.join("color_palette/data/colorhexa.com_colors.json")
                          |> File.read!()
                          |> Jason.decode!(keys: :atoms)

      # --------------------------------------------------------------------------------------------
      # Raw Data Converted to `ColorPalette.Color` structs:

      @color_data_api_colors @raw_color_data_api_data
                             |> DataConverter.convert_raw_color_data_to_colors(:color_data_api)
                             |> DataConverter.add_ansi_color_codes_to_colors(@ansi_color_codes)

      @color_name_dot_com_colors @raw_color_name_dot_com_data
                                 |> DataConverter.convert_raw_color_data_to_colors(:color_name_dot_com)
                                 |> DataConverter.add_ansi_color_codes_to_colors(@ansi_color_codes)

      @colorhexa_colors @raw_colorhexa_data
                        |> DataConverter.convert_raw_color_data_to_colors(:colorhexa)
                        |> DataConverter.add_ansi_color_codes_to_colors(@ansi_color_codes)

      @io_ansi_colors @io_ansi_color_names
                      |> DataConverter.convert_raw_color_data_to_colors(:io_ansi)
                      |> DataConverter.add_ansi_color_codes_to_colors(@ansi_color_codes)

      # --------------------------------------------------------------------------------------------
      # Tranformation & Grouping of the Data:

      @combined_colors DataConverter.multi_zip([
                         @io_ansi_colors ++ List.duplicate(nil, 256 - 16),
                         @color_data_api_colors,
                         @color_name_dot_com_colors,
                         @colorhexa_colors
                       ])

      # ----------------------

      @combined_colors_collated @combined_colors
                                |> DataConverter.collate_colors_with_same_name_for_code()
                                |> DataConverter.annotate_same_as_field()

      @colors_by_name @combined_colors_collated
                      |> DataConverter.group_by_name_frequency()
                      |> DataConverter.purge_orphaned_same_as_entries()

      @ansi_color_codes_missing_names @colors_by_name |> DataConverter.unnamed_ansi_color_codes()

      @generated_names_for_unnamed_colors DataConverter.create_names_for_missing_colors(
                                            @combined_colors,
                                            @ansi_color_codes_missing_names
                                          )

      # -------------------------------
      # The main colors data structure:
      @colors @colors_by_name |> Map.merge(@generated_names_for_unnamed_colors)

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
      def raw_color_data_api_data, do: @raw_color_data_api_data
      def raw_color_name_dot_com_data, do: @raw_color_name_dot_com_data
      def raw_colorhexa_data, do: @raw_colorhexa_data
      def ansi_color_codes, do: @ansi_color_codes
      def io_ansi_color_names, do: @io_ansi_color_names

      # ---------------------------------------------------
      # Raw Data converetd to `ColorPalette.Color` structs:

      def io_ansi_colors, do: @io_ansi_colors
      def color_name_dot_com_colors, do: @color_name_dot_com_colors
      def color_data_api_colors, do: @color_data_api_colors
      def colorhexa_colors, do: @colorhexa_colors
      def combined_colors, do: @combined_colors

      # -----------------------------
      # Transformed & Grouped Data:

      def combined_colors_collated, do: @combined_colors_collated
      def colors_by_name, do: @colors_by_name
      def ansi_color_codes_missing_names, do: @ansi_color_codes_missing_names
      def generated_names_for_unnamed_colors, do: @generated_names_for_unnamed_colors

      # -------------------------------
      @doc """
      The main colors data structure.  A map between the color name and the `ColorPalette.Color` struct
      """
      @spec colors() :: %{atom() => ColorPalette.Color.t()}
      def colors, do: @colors
    end
  end
end
