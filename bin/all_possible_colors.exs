#!/usr/bin/env elixir

defmodule Color do
  @names [
    :black,
    :light_black,
    :blue,
    :light_blue,
    :cyan,
    :light_cyan,
    :green,
    :light_green,
    :magenta,
    :light_magenta,
    :red,
    :light_red,
    :white,
    :light_white,
    :yellow,
    :light_yellow
  ]
  def names, do: @names

  def numbers do
    0..5
    |> Enum.reduce(MapSet.new(), fn i, acc ->
      0..5
      |> Enum.reduce(acc, fn j, acc ->
        0..5
        |> Enum.reduce(acc, fn k, acc ->
          MapSet.put(acc, {i, j, k})
        end)
      end)
    end)
    |> MapSet.to_list()
    |> Enum.sort()
  end
end

defmodule Print do
  import IO.ANSI

  @line_length 100

  @black_line black_background() <> String.pad_trailing("", @line_length) <> reset()
  @dashed_line String.pad_trailing("=", @line_length, "=")
  @lorem_ipsum "Lorem ipsum dolor sit amet, consectetur adipiscing elit"

  @border_color [0, 2, 5]
  @border apply(IO.ANSI, :color, @border_color)
  @border_background apply(IO.ANSI, :color_background, @border_color)
  @border_line @border <> @border_background <> @dashed_line <> reset()
  @border_column @border <> @border_background <> "  " <> reset()
  @border_line @border <> @border_background <> @dashed_line <> reset()

  @swatch_chars_length 8
  @swatch_chars String.pad_trailing("", @swatch_chars_length, " ")

  def pad_trailing(string), do: String.pad_trailing(string, @line_length)
  def blank_line, do: IO.puts(@black_line)
  def border_line, do: IO.puts(@border_line)

  def double_yellow_line do
    blank_line()
    IO.puts(black_background() <> light_yellow() <> @dashed_line <> reset())
    blank_line()
  end

  def status_line do
    blank_line()
    IO.puts(black_background() <> color(5, 2, 0) <> underline() <> pad_trailing("Generating all colors...") <> reset())
    blank_line()
  end

  def named_colors_table(color_names) do
    blank_line()
    IO.puts(black_background() <> light_green() <> italic() <> pad_trailing("  Named Colors:") <> reset())
    blank_line()
    blank_line()
    border_line()

    color_names
    |> Enum.each(fn color ->
      background_color = "#{color}_background" |> String.to_atom()

      IO.puts(
        @border_column <>
          apply(IO.ANSI, background_color, []) <>
          @swatch_chars <>
          reset() <>
          apply(IO.ANSI, color, []) <>
          black_background() <>
          "   :#{String.pad_trailing(Atom.to_string(color), @line_length - 83)} #{@lorem_ipsum}   " <>
          reset() <>
          apply(IO.ANSI, background_color, []) <>
          @swatch_chars <>
          reset() <>
          @border_column
      )
    end)

    border_line()
  end

  def numbered_colors_table(color_numbers) do
    IO.puts(
      black_background() <>
        light_green() <>
        italic() <>
        pad_trailing("    There are #{length(color_numbers)} unique numbered colors:") <> reset()
    )

    blank_line()
    border_line()

    color_numbers
    |> Enum.each(fn {i, j, k} ->
      IO.puts(
        @border_column <>
          color_background(i, j, k) <>
          @swatch_chars <>
          reset() <>
          color(i, j, k) <>
          black_background() <>
          String.pad_trailing("   color(#{i}, #{j}, #{k})", @line_length - 79, " ") <>
          " #{@lorem_ipsum}   " <>
          reset() <>
          color_background(i, j, k) <>
          @swatch_chars <>
          reset() <>
          @border_column
      )
    end)

    border_line()
  end

  def effects_that_work do
    success_color = light_green()
    IO.puts(light_yellow() <> "Works:" <> reset())
    IO.puts(success_color <> crossed_out() <> "crossed_out() - #{@lorem_ipsum}" <> reset())
    IO.puts(success_color <> italic() <> "italic()      - #{@lorem_ipsum}" <> reset())
    IO.puts(success_color <> underline() <> "underline()   - #{@lorem_ipsum}" <> reset())
  end

  def effects_that_do_not_work do
    fail_color = color(5, 2, 0)
    IO.puts(light_red() <> "\nDoes not work:" <> reset())
    IO.puts(fail_color <> encircled() <> "encircled()   - #{@lorem_ipsum}" <> reset())
    IO.puts(fail_color <> blink_rapid() <> "blink_rapid() - #{@lorem_ipsum}" <> reset())
    IO.puts(fail_color <> blink_slow() <> "blink_slow()  - #{@lorem_ipsum}" <> reset())
    IO.puts(fail_color <> framed() <> "framed()      - #{@lorem_ipsum}" <> reset())
    IO.puts(fail_color <> overlined() <> "overlined()   - #{@lorem_ipsum}" <> reset())
    IO.puts(fail_color <> font_1() <> "font_1()      - #{@lorem_ipsum}" <> reset())
    IO.puts(fail_color <> font_4() <> "font_4()      - #{@lorem_ipsum}" <> reset())
    IO.puts(fail_color <> font_9() <> "font_9()      - #{@lorem_ipsum}" <> reset())
  end
end

# -----------------------------------------------------------------------------------------

Print.status_line()
Print.named_colors_table(Color.names())
Print.double_yellow_line()
Print.numbered_colors_table(Color.numbers())
Print.blank_line()
Print.effects_that_work()
Print.effects_that_do_not_work()
Print.double_yellow_line()


