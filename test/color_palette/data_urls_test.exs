defmodule ColorPalette.DataURLsTest do
  @moduledoc false
  use ExUnit.Case

  alias ColorPalette.DataURLs

  describe "annotate" do
    test "returns the color as opts" do
      yellow_green = %ColorPalette.Color{
        name: :yellow_green,
        ansi_color_code: %ColorPalette.ANSIColorCode{code: 150, hex: "afd787", rgb: [175, 215, 135], color_group: nil},
        text_contrast_color: :black,
        source: :color_name_dot_com,
        color_data: [],
        same_as: [:feijoa]
      }

      opts = DataURLs.color_to_opts(yellow_green)

      assert opts == [hex: "afd787", name: :yellow_green]
    end
  end
end
