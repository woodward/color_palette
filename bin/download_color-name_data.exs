#!/usr/bin/env elixir

Mix.install([
  {:jason, "~> 1.4"},
  {:req, "~> 0.4"},
  {:floki, "~> 0.36"}
])

import IO.ANSI

IO.puts(light_yellow() <> "Downloading color data from color-name.com..." <> reset())

# Sample URL:
# https://www.color-name.com/hex/00ffff

ansi_color_code_filename = Path.join(__DIR__, "../lib/color_palette/ansi_color_codes.json")
color_codes = ansi_color_code_filename |> File.read!() |> Jason.decode!(keys: :atoms)

IO.puts(light_green() <> "There are #{length(color_codes)} color codes" <> reset())

code = color_codes |> hd()
IO.puts(light_blue() <> "First color code: #{inspect(code)}" <> reset())

# color_codes = color_codes |> Enum.take(5)
sleep_time_ms = 600

color_data =
  color_codes
  |> Enum.reduce({[], 0}, fn ansi_color_code, {data, index} ->
    IO.puts("==========================================")
    hex = ansi_color_code.hex
    IO.puts(light_yellow() <> "Index: #{index}.  Hex: #{hex}" <> reset())
    result_body = Req.get!("https://www.color-name.com/hex/#{hex}").body |> Floki.parse_document!()
    color_code = result_body |> Floki.find("h4.color-code") |> hd() |> Floki.text()

    text_color = result_body |> Floki.find("div.welcome-title-child h1") |> Floki.attribute("class") |> List.first()
    text_color = if text_color == "color-white", do: :white, else: :black

    name =
      color_code
      |> String.replace("\t", "")
      |> String.replace("\n", "")
      |> String.replace("Color Name: ", "")
      |> String.trim()

    {name, info} =
      case Regex.named_captures(~r/(?<name>.*) \((?<info>.*)\)/, name) do
        nil -> {name, nil}
        %{"info" => info, "name" => name} -> {String.trim(name), info}
      end

    IO.puts(light_green() <> "Color Name: #{name}   Extra info: #{info}   doc_text_color: #{text_color}" <> reset())
    Process.sleep(sleep_time_ms)
    {[%{name: name, hex: hex, extra: info, code: ansi_color_code.code, doc_text_color: text_color}] ++ data, index + 1}
  end)
  |> elem(0)
  |> Enum.reverse()

IO.puts(light_green() <> "Downloaded #{length(color_data)} color data items" <> reset())
IO.puts(light_yellow() <> "Writing color data to color-name.com_colors.json" <> reset())
File.write!("color-name.com_colors.json", Jason.encode!(color_data, pretty: true))
IO.puts(light_green() <> "Color data writen." <> reset())
