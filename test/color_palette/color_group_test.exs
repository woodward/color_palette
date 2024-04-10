defmodule ColorPalette.ColorGroupTest do
  @moduledoc false
  use ExUnit.Case

  alias ColorPalette.ColorGroup

  describe "groups/0" do
    test "returns the list of color groups" do
      assert ColorGroup.groups() == [
               :blue,
               :brown,
               :cyan,
               :gray_and_black,
               :green,
               :orange,
               :pink,
               :purple_violet_and_magenta,
               :red,
               :white,
               :yellow
             ]
    end
  end

  describe "ansi_color_codes_by_color_group" do
    test "returns the ansi colorcodes grouped by color group" do
      ansi_color_codes = [
        %{code: 0, color_group: :gray_and_black},
        %{code: 1, color_group: :gray_and_black},
        %{code: 2, color_group: :white},
        %{code: 3, color_group: :green},
        %{code: 4, color_group: :blue},
        %{code: 5, color_group: nil}
      ]

      ansi_color_codes_by_group = ColorGroup.ansi_color_codes_by_group(ansi_color_codes)

      assert ansi_color_codes_by_group == %{
               gray_and_black: [0, 1],
               white: [2],
               green: [3],
               blue: [4]
             }
    end
  end
end
