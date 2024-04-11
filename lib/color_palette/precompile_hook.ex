defmodule ColorPalette.PrecompileHook do
  @moduledoc false

  import ColorPalette.Color
  alias ColorPalette.ANSIColorCode

  defmacro __before_compile__(_env) do
    quote do
      alias ColorPalette.Utils

      @io_ansi_colors %{
        black: %{code: 0, doc_text_color: :white},
        red: %{code: 1, doc_text_color: :white},
        green: %{code: 2, doc_text_color: :white},
        yellow: %{code: 3, doc_text_color: :white},
        blue: %{code: 4, doc_text_color: :white},
        magenta: %{code: 5, doc_text_color: :white},
        cyan: %{code: 6, doc_text_color: :white},
        white: %{code: 7, doc_text_color: :black},
        #
        light_black: %{code: 8, doc_text_color: :white},
        light_red: %{code: 9, doc_text_color: :white},
        light_green: %{code: 10, doc_text_color: :white},
        light_yellow: %{code: 11, doc_text_color: :white},
        light_blue: %{code: 12, doc_text_color: :white},
        light_magenta: %{code: 13, doc_text_color: :white},
        light_cyan: %{code: 14, doc_text_color: :white},
        light_white: %{code: 15, doc_text_color: :black}
      }

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

      @color_data_api_raw_data __DIR__
                               |> Path.join("color_palette/color_data_api_colors.json")
                               |> Utils.read_json_file!()

      @color_name_dot_com_raw_data __DIR__
                                   |> Path.join("color_palette/color-name.com_colors.json")
                                   |> Utils.read_json_file!()

      @api_colors ColorPalette.ColorNames.convert_color_data_api_raw_data(@color_data_api_raw_data, @ansi_color_codes)
                  |> Map.merge(
                    ColorPalette.ColorNames.convert_color_name_dot_com_raw_data(@color_name_dot_com_raw_data, @ansi_color_codes)
                  )

      @colors @api_colors
              |> Map.merge(ColorPalette.ColorNames.convert_ansi_colors_to_color_names(@io_ansi_colors, @ansi_color_codes))
              |> ColorPalette.ColorNames.find_duplicates()

      @io_ansi_colors
      |> Map.keys()
      |> Enum.each(fn color ->
        delegate_to_io_ansi(color)
        delegate_to_io_ansi(String.to_atom("#{color}_background"))
      end)

      @api_colors
      |> Enum.each(fn {color_name, color} ->
        def_color(color_name, [color.ansi_color_code.code])
        background_name = "#{color_name}_background" |> String.to_atom()
        def_background_color(background_name, [color.ansi_color_code.code])
      end)

      def ansi_color_codes, do: @ansi_color_codes
      def color_data_api_raw_data, do: @color_data_api_raw_data
      def color_name_dot_com_raw_data, do: @color_name_dot_com_raw_data
      def api_colors, do: @api_colors
      def colors, do: @colors
      def io_ansi_colors, do: @io_ansi_colors
    end
  end
end
