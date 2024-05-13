defmodule ColorPalette.PrecompileHook do
  @moduledoc false

  # This hook is used to bring data and functions at compile-time into `ColorPalette`

  import ColorPalette.Color

  alias ColorPalette.ANSIColorCode
  alias ColorPalette.Color
  alias ColorPalette.ColorGroup
  alias ColorPalette.DataConverter

  defmacro __before_compile__(_env) do
    quote do
      # --------------------------------------------------------------------------------------------
      # Raw Data:

      # -------------------------
      # ANSI color code raw data:

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

      # --------------------
      # Color name raw data:

      @io_ansi_color_names __DIR__
                           |> Path.join("color_palette/data/ansi_color_names.json")
                           |> File.read!()
                           |> Jason.decode!(keys: :atoms)
                           |> Enum.map(&(&1 |> Map.merge(%{exact_name_match?: true, distance_to_closest_named_hex: 0})))

      @raw_color_data_api_data __DIR__
                               |> Path.join("color_palette/data/color_data_api_colors.json")
                               |> File.read!()
                               |> Jason.decode!(keys: :atoms)
                               |> Enum.with_index(fn data, code -> DataConverter.normalize_data(data, code) end)

      @raw_color_name_dot_com_data __DIR__
                                   |> Path.join("color_palette/data/color-name.com_colors.json")
                                   |> File.read!()
                                   |> Jason.decode!(keys: :atoms)

      @raw_colorhexa_data __DIR__
                          |> Path.join("color_palette/data/colorhexa.com_colors.json")
                          |> File.read!()
                          |> Jason.decode!(keys: :atoms)

      @raw_bunt_data __DIR__
                     |> Path.join("color_palette/data/bunt_colors.json")
                     |> File.read!()
                     |> Jason.decode!(keys: :atoms)

      @raw_name_that_color_data __DIR__
                                |> Path.join("color_palette/data/name_that_color_unique_colors.json")
                                |> File.read!()
                                |> Jason.decode!(keys: :atoms)

      # --------------------------------------------------------------------------------------------
      # Raw Data converted to `ColorPalette.Color` structs:

      @color_data_api_colors @raw_color_data_api_data
                             |> DataConverter.convert_raw_color_data_to_colors(:color_data_api, @ansi_color_codes)

      @color_name_dot_com_colors @raw_color_name_dot_com_data
                                 |> DataConverter.convert_raw_color_data_to_colors(:color_name_dot_com, @ansi_color_codes)

      @colorhexa_colors @raw_colorhexa_data
                        |> DataConverter.convert_raw_color_data_to_colors(:colorhexa, @ansi_color_codes)

      @name_that_color_colors @raw_name_that_color_data
                              |> DataConverter.convert_raw_color_data_to_colors(:name_that_color, @ansi_color_codes)

      @bunt_colors @raw_bunt_data
                   |> DataConverter.convert_raw_color_data_to_colors(:bunt, @ansi_color_codes)

      @io_ansi_colors @io_ansi_color_names
                      |> DataConverter.convert_raw_color_data_to_colors(:io_ansi, @ansi_color_codes)

      # --------------------------------------------------------------------------------------------
      # Tranformation & Grouping of the Data:

      @combined_colors (@io_ansi_colors ++
                          @color_data_api_colors ++
                          @color_name_dot_com_colors ++
                          @colorhexa_colors ++
                          @bunt_colors ++
                          @name_that_color_colors)
                       |> List.flatten()

      @combined_colors_collated @combined_colors
                                |> DataConverter.collate_colors_by_name()
                                |> DataConverter.combine_colors_with_same_name()

      @colors_by_name @combined_colors_collated |> DataConverter.group_by_name_frequency()

      @ansi_color_codes_missing_names @colors_by_name |> DataConverter.unnamed_ansi_color_codes()

      @generated_names_for_unnamed_colors DataConverter.create_names_for_missing_colors(
                                            @combined_colors,
                                            @ansi_color_codes_missing_names
                                          )

      colors_temp = @colors_by_name |> Map.merge(@generated_names_for_unnamed_colors)

      # ------------------------------------
      # The main two colors data structures:

      @hex_to_color_names colors_temp |> DataConverter.hex_to_color_names()

      @colors colors_temp |> DataConverter.fill_in_same_as_field(@hex_to_color_names)

      # --------------------------------------------------------------------------------------------
      # Generate `ColorPalette` functions for the colors:

      @colors
      |> Enum.each(fn {color_name, color} ->
        def_color(
          color_name,
          color.ansi_color_code.hex,
          color.text_contrast_color,
          color.same_as,
          color.source,
          color.ansi_color_code.color_group,
          color.ansi_color_code.code
        )
      end)

      # --------------------------------------------------------------------------------------------
      # Accessors
      # Most are here mostly just for debugging purposes (other than `colors/0`, `hex_to_color_names/0`,
      # and `ansi_color_codes/0`)
      # --------------------------------------------------------------------------------------------

      # Raw Data
      @doc false
      @spec color_groups_to_ansi_color_codes :: %{ColorGroup.t() => [ANSIColorCode.t()]}
      def color_groups_to_ansi_color_codes, do: @color_groups_to_ansi_color_codes

      @doc false
      @spec raw_color_data_api_data :: [map()]
      def raw_color_data_api_data, do: @raw_color_data_api_data

      @doc false
      @spec raw_color_name_dot_com_data :: [map()]
      def raw_color_name_dot_com_data, do: @raw_color_name_dot_com_data

      @doc false
      @spec raw_colorhexa_data :: [map()]
      def raw_colorhexa_data, do: @raw_colorhexa_data

      @doc false
      @spec raw_bunt_data :: [map()]
      def raw_bunt_data, do: @raw_bunt_data

      @doc false
      @spec raw_name_that_color_data :: [map()]
      def raw_name_that_color_data, do: @raw_name_that_color_data

      @doc false
      @spec io_ansi_color_names :: [map()]
      def io_ansi_color_names, do: @io_ansi_color_names

      # ---------------------------------------------------
      # Raw Data converted to `ColorPalette.Color` structs:

      @doc false
      @spec io_ansi_colors :: [[Color.t()]]
      def io_ansi_colors, do: @io_ansi_colors

      @doc false
      @spec color_name_dot_com_colors :: [[Color.t()]]
      def color_name_dot_com_colors, do: @color_name_dot_com_colors

      @doc false
      @spec color_data_api_colors :: [[Color.t()]]
      def color_data_api_colors, do: @color_data_api_colors

      @doc false
      @spec colorhexa_colors :: [[Color.t()]]
      def colorhexa_colors, do: @colorhexa_colors

      @doc false
      @spec bunt_colors :: [[Color.t()]]
      def bunt_colors, do: @bunt_colors

      @doc false
      @spec name_that_color_colors :: [[Color.t()]]
      def name_that_color_colors, do: @name_that_color_colors

      @doc false
      @spec combined_colors :: [Color.t()]
      def combined_colors, do: @combined_colors

      # ---------------------------
      # Transformed & grouped Data:

      @doc false
      @spec combined_colors_collated :: %{Color.name() => [Color.t()]}
      def combined_colors_collated, do: @combined_colors_collated

      @doc false
      @spec colors_by_name :: %{Color.name() => Color.t()}
      def colors_by_name, do: @colors_by_name

      @doc false
      @spec ansi_color_codes_missing_names :: [ANSIColorCode.code()]
      def ansi_color_codes_missing_names, do: @ansi_color_codes_missing_names

      @doc false
      @spec generated_names_for_unnamed_colors :: %{Color.name() => Color.t()}
      def generated_names_for_unnamed_colors, do: @generated_names_for_unnamed_colors

      # -------------------------------
      @doc """
      A list of the 256 ANSI color codes
      """
      @spec ansi_color_codes :: [ColorPalette.ANSIColorCode.t()]
      def ansi_color_codes, do: @ansi_color_codes

      @doc """
      The main colors data structure.  A map between the color name and the `ColorPalette.Color` struct
      """
      @spec colors() :: %{ColorPalette.Color.name() => ColorPalette.Color.t()}
      def colors, do: @colors

      @doc """
      A mapping between the ANSI color hex value and the color names associated with that hex value.
      """
      @spec hex_to_color_names :: %{ColorPalette.ANSIColorCode.hex() => [ColorPalette.Color.name()]}
      def hex_to_color_names, do: @hex_to_color_names
    end
  end
end
