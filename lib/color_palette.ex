defmodule ColorPalette do
  @moduledoc false

  defdelegate reset(), to: IO.ANSI

  @before_compile ColorPalette.FooBar
end
