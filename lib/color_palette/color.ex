defmodule ColorPalette.Color do
  @moduledoc false

  defstruct [
    :name,
    :ansi_color_code,
    :text_contrast_color,
    # :source can be one of :io_ansi, :color_name_dot_com, or :color_data_api:
    :source,
    color_data: [],
    same_as: []
  ]

  defmacro def_color(name, hex, text_contrast_color, code) do
    quote bind_quoted: [name: name, text_contrast_color: text_contrast_color, hex: hex, code: code] do
      @doc """
      <div style="color: #{text_contrast_color}; background-color: ##{hex}; padding: 1rem;">
      Sets foreground color to <strong>#{name}</strong>.  Hex value ##{hex}.  ANSI code #{code}.
      </div>
      """
      def unquote(name)() do
        apply(IO.ANSI, :color, unquote(code))
      end

      def unquote(String.to_atom("#{name}_background"))() do
        apply(IO.ANSI, :color_background, unquote(code))
      end
    end
  end

  defmacro delegate_to_io_ansi(name, hex, text_contrast_color, code) do
    quote bind_quoted: [name: name, text_contrast_color: text_contrast_color, hex: hex, code: code] do
      @doc """
      <div style="color: #{text_contrast_color}; background-color: ##{hex}; padding: 1rem;">
      See
      <a href="https://hexdocs.pm/elixir/IO.ANSI.html##{name}/0">IO.ANSI.#{name}</a>
      <br />
      Hex value ##{hex}.  ANSI code #{code}.
      </div>
      """
      defdelegate unquote(name)(), to: IO.ANSI
    end
  end
end
