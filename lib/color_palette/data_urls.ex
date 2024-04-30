defmodule ColorPalette.DataURLs do
  @moduledoc false

  alias ColorPalette.Color

  @spec url(Color.source(), Keyword.t()) :: String.t()
  def url(type, opts) do
    name = Keyword.get(opts, :name)
    hex = Keyword.get(opts, :hex)
    format = Keyword.get(opts, :format, :html)

    case type do
      :io_ansi -> "https://hexdocs.pm/elixir/IO.ANSI.html##{name}/0"
      :colorhexa -> "https://www.colorhexa.com/#{hex}"
      :color_name_dot_com -> "https://www.color-name.com/hex/#{hex}"
      :name_that_color -> "https://chir.ag/projects/name-that-color/##{hex}"
      :color_data_api -> "https://www.thecolorapi.com/id?hex=#{hex}&format=#{format}"
      :bunt -> "https://github.com/rrrene/bunt/blob/master/lib/bunt_ansi.ex"
      type -> raise "Unsupported data URL type: #{type}"
    end
  end
end
