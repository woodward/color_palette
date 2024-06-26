#!/usr/bin/env elixir

Mix.install([
  {:jason, "~> 1.4"},
  {:req, "~> 0.4"},
  {:floki, "~> 0.36"},
  {:color_palette, path: Path.join(__DIR__, "../")}
])

import IO.ANSI

IO.puts(light_yellow() <> "Downloading color data from colorhexa.com..." <> reset())

# Sample URL:
# https://www.colorhexa.com/fffacd

ansi_color_code_filename = Path.join(__DIR__, "../lib/color_palette/data/ansi_color_codes.json")
color_codes = ansi_color_code_filename |> File.read!() |> Jason.decode!(keys: :atoms)

IO.puts(light_green() <> "There are #{length(color_codes)} color codes" <> reset())

code = color_codes |> hd()
IO.puts(light_blue() <> "First color code: #{inspect(code)}" <> reset())

# color_codes = color_codes |> Enum.take(30)
sleep_time_ms = 600

color_data =
  color_codes
  |> Enum.reduce({[], 0}, fn ansi_color_code, {data, index} ->
    IO.puts("==========================================")
    hex = ansi_color_code.hex
    IO.puts(light_yellow() <> "Index: #{index}.  Hex: #{hex}" <> reset())
    url = ColorPalette.DataURLs.url(:colorhexa, hex: hex)
    result_body = Req.get!(url).body |> Floki.parse_document!()
    color_name = result_body |> Floki.find("#header-title") |> hd() |> Floki.text()

    color_name =
      if String.contains?(color_name, "/") do
        color_name |> String.split("/") |> List.first() |> String.trim()
      else
        result_body |> Floki.find(".color-description p strong") |> Floki.text()
      end

    # There will be either a class "tw" (for text-white) or "tb" (for text-black) on this element:
    demo_element_classes = result_body |> Floki.find("#preview .color-demo .demo p") |> Floki.attribute("class")
    text_contrast_color = if "tw" in demo_element_classes, do: :white, else: :black

    IO.puts(light_green() <> "Hex: #{hex}  text_contrast_color: #{text_contrast_color}  Color Name: #{color_name}" <> reset())
    Process.sleep(sleep_time_ms)
    {[%{name: color_name, hex: hex, code: ansi_color_code.code, text_contrast_color: text_contrast_color}] ++ data, index + 1}
  end)
  |> elem(0)
  |> Enum.reverse()

IO.puts(light_green() <> "Downloaded #{length(color_data)} color data items" <> reset())
IO.puts(light_yellow() <> "Writing color data to colorhexa.com_colors.json" <> reset())
File.write!("colorhexa.com_colors.json", Jason.encode!(color_data, pretty: true))
IO.puts(light_green() <> "Color data writen." <> reset())
