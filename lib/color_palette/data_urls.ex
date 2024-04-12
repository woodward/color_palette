defmodule ColorPalette.DataURLs do
  @moduledoc false

  def url(:color_name_dot_com, hex: hex), do: "https://www.color-name.com/hex/#{hex}"
  def url(:io_ansi, name: color), do: "https://hexdocs.pm/elixir/IO.ANSI.html##{color}/0"
  def url(:colorhexa, hex: hex), do: "https://www.colorhexa.com/#{hex}"

  def url(:color_data_api, opts) do
    format = Keyword.get(opts, :format, :html)
    hex = Keyword.get(opts, :hex)
    "https://www.thecolorapi.com/id?hex=#{hex}&format=#{format}"
  end

  def color_to_opts(color) do
    ansi_color_code = color.ansi_color_code
    [hex: ansi_color_code.hex, name: color.name]
  end
end
