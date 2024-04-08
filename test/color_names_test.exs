defmodule ColorNamesTest do
  use ExUnit.Case
  doctest ColorNames

  describe "functions which delegate to IO.ANSI" do
    test "reset() delegates to IO.ANSI" do
      assert ColorNames.reset() == IO.ANSI.reset()
    end
  end
end
