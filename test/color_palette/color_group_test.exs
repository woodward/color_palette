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
end
