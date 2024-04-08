defmodule ColorNamesTest do
  use ExUnit.Case
  doctest ColorNames

  describe "functions which delegate to IO.ANSI" do
    test "reset() delegates to IO.ANSI" do
      assert ColorNames.reset() == IO.ANSI.reset()
    end
  end

  describe "ansi_color_codes" do
    test "returns the list of ansi color codes" do
      color_codes = ColorNames.ansi_color_codes()
      assert length(color_codes) == 256

      first_code = color_codes |> List.first()

      assert first_code == %{
               code: 0,
               hex: "000000",
               rgb: [0, 0, 0]
             }

      last_code = color_codes |> List.last()

      assert last_code == %{
               code: 255,
               hex: "eeeeee",
               rgb: [238, 238, 238]
             }
    end
  end
end
