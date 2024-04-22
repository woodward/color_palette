defmodule ColorPalette.ANSIColorCodeTest do
  @moduledoc false
  use ExUnit.Case

  describe "exploration - see how many non-unique hex values are in the list of ANSI color codes" do
    test "check for uniqueness of the hex values of the ANSI color codes" do
      # Note that this test is not actually testing anything; it is just exploring
      # the ANSI color code data

      ansi_color_codes = ColorPalette.ansi_color_codes()
      assert length(ansi_color_codes) == 256

      non_unique =
        ansi_color_codes
        |> Enum.reduce(%{}, fn ansi_color_code, acc ->
          Map.update(acc, ansi_color_code.hex, [ansi_color_code.code], &([ansi_color_code.code] ++ &1))
        end)
        |> Enum.filter(fn {_hex, codes} -> length(codes) > 1 end)
        |> Enum.map(fn {hex, codes} -> {hex, Enum.sort(codes)} end)
        |> Enum.sort()

      # There are 9 non-unique ANSI codes (with the same hex value as another)
      # So there are really just 256 - 9 = 247 unique codes
      assert length(non_unique) == 9

      assert non_unique == [
               {"000000", [0, 16]},
               {"0000ff", [12, 21]},
               {"00ff00", [10, 46]},
               {"00ffff", [14, 51]},
               {"808080", [8, 244]},
               {"ff0000", [9, 196]},
               {"ff00ff", [13, 201]},
               {"ffff00", [11, 226]},
               {"ffffff", [15, 231]}
             ]
    end
  end
end
