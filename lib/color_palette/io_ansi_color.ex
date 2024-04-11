defmodule ColorPalette.IoAnsiColor do
  @moduledoc false

  @colors %{
    black: %{code: 0, doc_text_color: :white},
    red: %{code: 1, doc_text_color: :white},
    green: %{code: 2, doc_text_color: :white},
    yellow: %{code: 3, doc_text_color: :white},
    blue: %{code: 4, doc_text_color: :white},
    magenta: %{code: 5, doc_text_color: :white},
    cyan: %{code: 6, doc_text_color: :white},
    white: %{code: 7, doc_text_color: :black},
    #
    light_black: %{code: 8, doc_text_color: :white},
    light_red: %{code: 9, doc_text_color: :white},
    light_green: %{code: 10, doc_text_color: :white},
    light_yellow: %{code: 11, doc_text_color: :white},
    light_blue: %{code: 12, doc_text_color: :white},
    light_magenta: %{code: 13, doc_text_color: :white},
    light_cyan: %{code: 14, doc_text_color: :white},
    light_white: %{code: 15, doc_text_color: :black}
  }

  def colors, do: @colors
end
