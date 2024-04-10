defmodule ColorPalette do
  @moduledoc """
  Foo
  """

  defdelegate reset(), to: IO.ANSI

  @before_compile ColorPalette.FooBar
end
