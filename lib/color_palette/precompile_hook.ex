defmodule ColorPalette.PrecompileHook do
  @moduledoc false

  import ColorPalette.Color

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color
  alias ColorPalette.ColorGroup
  alias ColorPalette.DataConverter

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

      # Some of the ANSI color codes have the same hex value;
      # these are the duplicates:
      @ansi_codes_with_same_hex_value %{
        "000000" => [0, 16],
        "0000ff" => [12, 21],
        "00ff00" => [10, 46],
        "00ffff" => [14, 51],
        "808080" => [8, 244],
        "ff0000" => [9, 196],
        "ff00ff" => [13, 201],
        "ffff00" => [11, 226],
        "ffffff" => [15, 231]
      }

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
      # |> DataConverter.annotate_same_as_field()

      @colors_by_name @combined_colors_collated
                      |> DataConverter.group_by_name_frequency()
      # |> DataConverter.purge_orphaned_same_as_entries()

      @ansi_color_codes_missing_names @colors_by_name |> DataConverter.unnamed_ansi_color_codes()

      @generated_names_for_unnamed_colors DataConverter.create_names_for_missing_colors(
                                            @combined_colors,
                                            @ansi_color_codes_missing_names
                                          )

      # -------------------------------
      # The main colors data structure:
      @colors_temp @colors_by_name
                   |> Map.merge(@generated_names_for_unnamed_colors)
      #  |> DataConverter.annotate_same_as_field_for_duplicate_code_hexes(@ansi_codes_with_same_hex_value)

      @hex_to_color_names @colors_temp |> DataConverter.hex_to_color_names()

      @colors @colors_temp |> DataConverter.fill_in_same_as_field(@hex_to_color_names)

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
      # Most are here just for debugging purposes, other than `colors/0` and `ansi_color_codes/0`
      # --------------------------------------------------------------------------------------------

      # Raw Data
      @spec color_groups_to_ansi_color_codes :: %{ColorGroup.t() => [ANSIColorCode.t()]}
      def color_groups_to_ansi_color_codes, do: @color_groups_to_ansi_color_codes

      @spec raw_color_data_api_data :: [map()]
      def raw_color_data_api_data, do: @raw_color_data_api_data

      @spec raw_color_name_dot_com_data :: [map()]
      def raw_color_name_dot_com_data, do: @raw_color_name_dot_com_data

      @spec raw_colorhexa_data :: [map()]
      def raw_colorhexa_data, do: @raw_colorhexa_data

      @spec ansi_color_codes :: [ANSIColorCode.t()]
      def ansi_color_codes, do: @ansi_color_codes

      @doc """
      Some of the ANSI color codes have the same hex value; this is a mapping between
      the hex value and the duplicate color codes.
      """
      @spec ansi_codes_with_same_hex_value :: %{ANSIColorCode.hex() => [ANSIColorCode.code()]}
      def ansi_codes_with_same_hex_value, do: @ansi_codes_with_same_hex_value

      @spec io_ansi_color_names :: [map()]
      def io_ansi_color_names, do: @io_ansi_color_names

      # ---------------------------------------------------
      # Raw Data converted to `ColorPalette.Color` structs:

      @spec io_ansi_colors :: [[Color.t()]]
      def io_ansi_colors, do: @io_ansi_colors

      @spec color_name_dot_com_colors :: [[Color.t()]]
      def color_name_dot_com_colors, do: @color_name_dot_com_colors

      @spec color_data_api_colors :: [[Color.t()]]
      def color_data_api_colors, do: @color_data_api_colors

      @spec colorhexa_colors :: [[Color.t()]]
      def colorhexa_colors, do: @colorhexa_colors

      @spec combined_colors :: [[Color.t()]]
      def combined_colors, do: @combined_colors

      # ---------------------------
      # Transformed & Grouped Data:

      @spec combined_colors_collated :: [[Color.t()]]
      def combined_colors_collated, do: @combined_colors_collated

      @spec colors_by_name :: %{Color.name() => Color.t()}
      def colors_by_name, do: @colors_by_name

      @spec ansi_color_codes_missing_names :: [ANSIColorCode.code()]
      def ansi_color_codes_missing_names, do: @ansi_color_codes_missing_names

      @spec generated_names_for_unnamed_colors :: %{Color.name() => Color.t()}
      def generated_names_for_unnamed_colors, do: @generated_names_for_unnamed_colors

      # -------------------------------
      @doc """
      The main colors data structure.  A map between the color name and the `ColorPalette.Color` struct
      """
      @spec colors() :: %{Color.name() => Color.t()}
      def colors, do: @colors

      @spec hex_to_color_names :: %{ANSIColorCode.hex() => [Color.name()]}
      def hex_to_color_names, do: @hex_to_color_names
    end
  end
end
