defmodule ColorPalette.UtilsTest do
  @moduledoc false
  use ExUnit.Case

  alias ColorPalette.Utils

  describe "read_json_file" do
    test "reads in the JSON file with the colors" do
      colors = Utils.read_json_file!("lib/color_palette/ansi_color_codes.json")
      assert length(colors) == 256
      first_color = colors |> List.first()
      assert first_color == %{code: 0, hex: "000000", rgb: [0, 0, 0]}
      last_color = colors |> List.last()
      assert last_color == %{code: 255, hex: "eeeeee", rgb: [238, 238, 238]}
    end
  end
end
