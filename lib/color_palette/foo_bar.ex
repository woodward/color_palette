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

      @colors ColorPalette.ColorNames.collate(@ansi_color_codes, @color_data)

      @colors
      |> Enum.each(fn {color_name, color} ->
        def_color(color_name, [color.ansi_color_code.code])
        background_name = "#{color_name}_background" |> String.to_atom()
        def_background_color(background_name, [color.ansi_color_code.code])
      end)

      def ansi_color_codes, do: @ansi_color_codes
      def color_data, do: @color_data
      def colors, do: @colors
    end
  end

  def read_json_file!(filename), do: filename |> File.read!() |> Jason.decode!(keys: :atoms)
end
