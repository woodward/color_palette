defmodule ColorPalette.FooBar do
  @moduledoc false

  import ColorPalette.Color
  # alias ColorPalette.Color
  alias ColorPalette.ANSIColorCode

  defmacro __before_compile__(_env) do
    quote do
      alias ColorPalette.Utils

      @ansi_color_codes_by_group Path.join(__DIR__, "color_palette/ansi_color_codes_by_group.json")
                                 |> Utils.read_json_file!()
                                 |> Enum.map(&if &1.color_group, do: String.to_atom(&1.color_group), else: nil)

      @ansi_color_codes Path.join(__DIR__, "color_palette/ansi_color_codes.json")
                        |> Utils.read_json_file!()
                        |> Enum.zip(@ansi_color_codes_by_group)
                        |> Enum.map(fn {ansi_color_code, color_group} ->
                          Map.put(ansi_color_code, :color_group, color_group)
                        end)
                        |> Enum.map(&(%ANSIColorCode{} |> Map.merge(&1)))

      @color_data_api_data Path.join(__DIR__, "color_palette/color_data_api_colors.json") |> Utils.read_json_file!()
      @color_name_dot_com_data Path.join(__DIR__, "color_palette/color-name.com_colors.json") |> Utils.read_json_file!()

      @colors ColorPalette.ColorNames.convert_color_data_api_data(@ansi_color_codes, @color_data_api_data)
              |> Map.merge(ColorPalette.ColorNames.convert_color_name_dot_com_data(@ansi_color_codes, @color_name_dot_com_data))

      @all_colors @colors
                  |> Map.merge(
                    ColorPalette.ColorNames.convert_ansi_colors_to_color_names(
                      @ansi_color_codes,
                      ColorPalette.ANSIColorCode.io_ansi_colors()
                    )
                  )
                  |> ColorPalette.ColorNames.find_duplicates()

      ColorPalette.ANSIColorCode.io_ansi_colors()
      |> Map.keys()
      |> Enum.each(fn color ->
        delegate_to_io_ansi(color)
        delegate_to_io_ansi(String.to_atom("#{color}_background"))
      end)

      @colors
      |> Enum.each(fn {color_name, color} ->
        def_color(color_name, [color.ansi_color_code.code])
        background_name = "#{color_name}_background" |> String.to_atom()
        def_background_color(background_name, [color.ansi_color_code.code])
      end)

      def ansi_color_codes, do: @ansi_color_codes
      def ansi_color_codes_by_group, do: @ansi_color_codes_by_group
      def color_data_api_data, do: @color_data_api_data
      def color_name_dot_com_data, do: @color_name_dot_com_data
      def colors, do: @colors
      def all_colors, do: @all_colors

      defdelegate io_ansi_colors, to: ColorPalette.ANSIColorCode
    end
  end
end
