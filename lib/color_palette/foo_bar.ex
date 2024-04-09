defmodule ColorPalette.FooBar do
  @moduledoc false

  import ColorPalette.Color

  defmacro __before_compile__(_env) do
    quote do
      @ansi_color_codes Path.join(__DIR__, "color_palette/ansi_color_codes.json")
                        |> ColorPalette.FooBar.read_json_file!()

      @color_data Path.join(__DIR__, "color_palette/color_data.json")
                  |> ColorPalette.FooBar.read_json_file!()

      @colors ColorPalette.ColorNames.collate(@ansi_color_codes, @color_data)

      @colors
      |> Enum.each(fn {color_name, colors} ->
        case colors do
          [] ->
            # I don't think I'll ever reach here...
            :ok

          colors ->
            first_color = colors |> List.first()
            def_color(color_name, [first_color.ansi_code])
            background_name = "#{color_name}_background" |> String.to_atom()
            def_background_color(background_name, [first_color.ansi_code])
        end
      end)

      def ansi_color_codes, do: @ansi_color_codes
      def color_data, do: @color_data
      def colors, do: @colors
    end
  end

  def read_json_file!(filename), do: filename |> File.read!() |> Jason.decode!(keys: :atoms)
end
