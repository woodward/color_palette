defmodule ColorNames.FooBar do
  @moduledoc false

  defmacro __before_compile__(_env) do
    quote do
      @ansi_color_codes Path.join(__DIR__, "color_names/ansi_color_codes.json")
                        |> ColorNames.FooBar.read_json_file!()

      @color_data Path.join(__DIR__, "color_names/color_data.json")
                  |> ColorNames.FooBar.read_json_file!()

      # @colors
      # |> Enum.each(fn color ->
      #   case color.names do
      #     [] ->
      #       color_name = "color_#{color.code}"
      #       def_color(String.to_atom(color_name), [color.code])
      #       background_name = (color_name <> "_background") |> String.to_atom()
      #       def_background_color(background_name, [color.code])

      #     names ->
      #       names
      #       |> Enum.each(fn color_name ->
      #         def_color(String.to_atom(color_name), [color.code])
      #         background_name = (color_name <> "_background") |> String.to_atom()
      #         def_background_color(background_name, [color.code])
      #       end)
      #   end
      # end)

      def ansi_color_codes, do: @ansi_color_codes
      def color_data, do: @color_data
    end
  end

  def read_json_file!(filename), do: filename |> File.read!() |> Jason.decode!(keys: :atoms)
end
