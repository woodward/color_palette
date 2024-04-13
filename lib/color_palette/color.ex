defmodule ColorPalette.Color do
  @moduledoc """
  A struct which represents one of the 255 ANSI colors.
  """

  defstruct [
    :name,
    :ansi_color_code,
    :text_contrast_color,
    # :source can be one of :io_ansi, :color_name_dot_com, or :color_data_api:
    :source,
    color_data: [],
    same_as: []
  ]

  defmacro def_color(name, hex, text_contrast_color, same_as, source, code) do
    quote bind_quoted: [
            name: name,
            text_contrast_color: text_contrast_color,
            hex: hex,
            code: code,
            source: source,
            same_as: same_as
          ] do
      @doc """
      <div style="color: #{text_contrast_color}; background-color: ##{hex}; padding: 1rem;">
      Sets foreground color to <strong>#{name}</strong>.  Hex value ##{hex}.  ANSI code #{code}.
      <br />
      #{ColorPalette.ExDocUtils.source_link(source, text_contrast_color, hex)}
      #{ColorPalette.ExDocUtils.same_as(same_as, hex, text_contrast_color)}
      </div>
      """
      def unquote(name)() do
        apply(IO.ANSI, :color, unquote([code]))
      end

      @doc false
      def unquote(String.to_atom("#{name}_background"))() do
        apply(IO.ANSI, :color_background, unquote([code]))
      end
    end
  end

  defmacro delegate_to_io_ansi(name, hex, text_contrast_color, code) do
    quote bind_quoted: [name: name, text_contrast_color: text_contrast_color, hex: hex, code: code] do
      @doc """
      <div style="color: #{text_contrast_color}; background-color: ##{hex}; padding: 1rem;">
      See
      <a style="color: #{text_contrast_color}; background-color: ##{hex}; padding-right: 3rem;" href="https://hexdocs.pm/elixir/IO.ANSI.html##{name}/0">IO.ANSI.#{name}/0</a>
      Hex value ##{hex}.  ANSI code #{code}.
      </div>
      """
      defdelegate unquote(name)(), to: IO.ANSI

      @doc false
      defdelegate unquote(String.to_atom("#{name}_background"))(), to: IO.ANSI
    end
  end
end
