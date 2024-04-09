defmodule ColorPalette.Color do
  @moduledoc false

  defmacro def_color(name, code) do
    quote bind_quoted: [name: name, code: code] do
      @spec unquote(name)() :: String.t()
      def unquote(name)() do
        apply(IO.ANSI, :color, unquote(code))
      end
    end
  end

  defmacro def_background_color(name, code) do
    quote bind_quoted: [name: name, code: code] do
      @spec unquote(name)() :: String.t()
      def unquote(name)() do
        apply(IO.ANSI, :color_background, unquote(code))
      end
    end
  end
end
