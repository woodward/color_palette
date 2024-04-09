#!/usr/bin/env elixir

Mix.install([
  {:jason, "~> 1.4"},
  {:req, "~> 0.4"}
])

import IO.ANSI

IO.puts(light_yellow() <> "Downloading color data from thecolorapi.com..." <> reset())

# Sample URL:
# https://www.thecolorapi.com/id?hex=00ffff&format=json

ansi_color_code_filename = Path.join(__DIR__, "../lib/color_palette/ansi_color_codes.json")
color_codes = ansi_color_code_filename |> File.read!() |> Jason.decode!(keys: :atoms)

IO.puts(light_green() <> "There are #{length(color_codes)} color codes" <> reset())

code = color_codes |> hd()
IO.puts(light_blue() <> "First color code: #{inspect(code)}" <> reset())

# color_codes = color_codes |> Enum.take(3)
sleep_time = 400

color_data =
  color_codes
  |> Enum.reduce({[], 0}, fn code, {data, index} ->
    IO.puts("==========================================")
    IO.puts(light_yellow() <> "Index: #{index}.  Hex: #{code.hex}" <> reset())
    result_body = Req.get!("https://www.thecolorapi.com/id?hex=#{code.hex}&format=json").body
    Process.sleep(sleep_time)
    {[result_body] ++ data, index + 1}
  end)
  |> elem(0)
  |> Enum.reverse()

IO.puts(light_green() <> "Downloaded #{length(color_data)} color data items" <> reset())
IO.puts(light_yellow() <> "Writing color data to color_data_api_colors.json" <> reset())
File.write!("color_data_api_colors.json", Jason.encode!(color_data, pretty: true))
IO.puts(light_green() <> "Color data writen." <> reset())
