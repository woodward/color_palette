defmodule ColorPalette.FooBar do
  @moduledoc false

  import ColorPalette.Color
  # alias ColorPalette.Color
  alias ColorPalette.ANSIColorCode

  defmacro __before_compile__(_env) do
    quote do
      @ansi_color_codes Path.join(__DIR__, "color_palette/ansi_color_codes.json")
                        |> ColorPalette.FooBar.read_json_file!()
                        |> Enum.map(&(%ANSIColorCode{} |> Map.merge(&1)))

      @color_data Path.join(__DIR__, "color_palette/color_data_api_colors.json")
                  |> ColorPalette.FooBar.read_json_file!()

      @color_name_dot_com_data Path.join(__DIR__, "color_palette/color-name.com_colors.json")
                               |> ColorPalette.FooBar.read_json_file!()

      @colors ColorPalette.ColorNames.collate(@ansi_color_codes, @color_data)
              |> Map.merge(ColorPalette.ColorNames.convert_color_name_dot_com_data(@ansi_color_codes, @color_name_dot_com_data))

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

      @all_colors @colors
                  |> Map.merge(ColorPalette.ColorNames.convert_ansi_colors_to_color_names(@ansi_color_codes, @io_ansi_colors))

      @io_ansi_colors
      |> Map.keys()
      |> Enum.each(fn color ->
        if !String.starts_with?(Atom.to_string(color), "light_") do
          delegate_to_io_ansi(color)
          delegate_to_io_ansi(String.to_atom("#{color}_background"))
          delegate_to_io_ansi(String.to_atom("light_#{color}"))
          delegate_to_io_ansi(String.to_atom("light_#{color}_background"))
        end
      end)

      @colors
      |> Enum.each(fn {color_name, color} ->
        def_color(color_name, [color.ansi_color_code.code])
        background_name = "#{color_name}_background" |> String.to_atom()
        def_background_color(background_name, [color.ansi_color_code.code])
      end)

      def ansi_color_codes, do: @ansi_color_codes
      def color_data, do: @color_data
      def color_name_dot_com_data, do: @color_name_dot_com_data
      def colors, do: @colors
      def all_colors, do: @all_colors
      def io_ansi_colors, do: @io_ansi_colors
    end
  end

  def read_json_file!(filename), do: filename |> File.read!() |> Jason.decode!(keys: :atoms)
end
