defmodule ColorPalette.DataURLs do
  @moduledoc false

  def color_name_dot_com_html(hex), do: "https://www.color-name.com/hex/#{hex}"
  def colorhexa_html(hex), do: "https://www.colorhexa.com/#{hex}"

  def color_api_data(hex), do: "https://www.thecolorapi.com/id?hex=#{hex}&format=json"
  def color_api_html(hex), do: "https://www.thecolorapi.com/id?hex=#{hex}&format=html"
end
