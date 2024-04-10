#!/usr/bin/env elixir

Mix.install([
  {:jason, "~> 1.4"},
  {:req, "~> 0.4"},
  {:floki, "~> 0.36"}
])

import IO.ANSI

IO.puts(light_yellow() <> "Downloading color data from colorhexa.com..." <> reset())

# Sample URL:
# https://www.colorhexa.com/fffacd

ansi_color_code_filename = Path.join(__DIR__, "../lib/color_palette/ansi_color_codes.json")
color_codes = ansi_color_code_filename |> File.read!() |> Jason.decode!(keys: :atoms)

IO.puts(light_green() <> "There are #{length(color_codes)} color codes" <> reset())

code = color_codes |> hd()
IO.puts(light_blue() <> "First color code: #{inspect(code)}" <> reset())

# color_codes = color_codes |> Enum.take(20)
sleep_time_ms = 600

color_data =
  color_codes
  |> Enum.reduce({[], 0}, fn ansi_color_code, {data, index} ->
    IO.puts("==========================================")
    hex = ansi_color_code.hex
    IO.puts(light_yellow() <> "Index: #{index}.  Hex: #{hex}" <> reset())
    result_body = Req.get!("https://www.colorhexa.com/#{hex}").body |> Floki.parse_document!()
    color_name = result_body |> Floki.find("#header-title") |> hd() |> Floki.text()

    color_name =
      if String.contains?(color_name, "/") do
        color_name |> String.split("/") |> List.first() |> String.trim()
      else
        result_body |> Floki.find(".color-description p strong") |> Floki.text()
      end

    IO.puts(light_green() <> "Hex: #{hex}  Color Name: #{color_name}" <> reset())
    Process.sleep(sleep_time_ms)
    {[%{name: color_name, hex: hex, code: ansi_color_code.code}] ++ data, index + 1}
  end)
  |> elem(0)
  |> Enum.reverse()

IO.puts(light_green() <> "Downloaded #{length(color_data)} color data items" <> reset())
IO.puts(light_yellow() <> "Writing color data to colorhexa.com_colors.json" <> reset())
File.write!("colorhexa.com_colors.json", Jason.encode!(color_data, pretty: true))
IO.puts(light_green() <> "Color data writen." <> reset())
