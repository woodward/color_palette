defmodule ColorPalette.Color do
  @moduledoc """
  A struct which represents one of the 255 ANSI colors.
  """

  alias ColorPalette.ExDocUtils
  alias ColorPalette.ANSIColorCode

  @type text_contrast_color :: :white | :black

  @type source :: :io_ansi | :colorhexa | :color_name_dot_com | :color_data_api

  @type name :: atom()

  @type t() :: %__MODULE__{
          name: name(),
          ansi_color_code: ANSIColorCode.t(),
          text_contrast_color: text_contrast_color(),
          closest_named_hex: String.t() | nil,
          distance_to_closest_named_hex: integer() | nil,
          source: [source()],
          exact_name_match?: boolean() | nil,
          renamed?: boolean(),
          same_as: [name()]
        }

  defstruct [
    :name,
    :ansi_color_code,
    :text_contrast_color,
    :closest_named_hex,
    :distance_to_closest_named_hex,
    source: [],
    exact_name_match?: false,
    renamed?: false,
    same_as: []
  ]

  defmacro def_color(name, hex, text_contrast_color, same_as, source, color_group, code) do
    quote bind_quoted: [
            name: name,
            text_contrast_color: text_contrast_color,
            hex: hex,
            code: code,
            color_group: color_group,
            source: source,
            same_as: same_as
          ] do
      @doc """
      <div style="color: #{text_contrast_color}; background-color: ##{hex}; padding: 1rem;">
      Sets foreground color to <strong>#{name}</strong>.  Hex value ##{hex}.  ANSI code #{code}.
      <br />
      #{ExDocUtils.source_links(source, text_contrast_color, hex, name)}
      #{ExDocUtils.same_as(same_as, hex, text_contrast_color)}
      #{ExDocUtils.color_group_link(hex, text_contrast_color, color_group)}
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

  defmacro delegate_to_io_ansi(name, hex, text_contrast_color, color_group, code) do
    quote bind_quoted: [name: name, text_contrast_color: text_contrast_color, hex: hex, color_group: color_group, code: code] do
      @doc """
      <div style="color: #{text_contrast_color}; background-color: ##{hex}; padding: 1rem;">
      See
      <a style="color: #{text_contrast_color}; background-color: ##{hex}; padding-right: 3rem;" href="https://hexdocs.pm/elixir/IO.ANSI.html##{name}/0">IO.ANSI.#{name}/0</a>
      Hex value ##{hex}.  ANSI code #{code}.
      #{ExDocUtils.color_group_link(hex, text_contrast_color, color_group)}
      </div>
      """
      defdelegate unquote(name)(), to: IO.ANSI

      @doc false
      defdelegate unquote(String.to_atom("#{name}_background"))(), to: IO.ANSI
    end
  end
end
