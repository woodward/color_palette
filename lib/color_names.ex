defmodule ColorNames do
  @moduledoc false

  defdelegate reset(), to: IO.ANSI

  @before_compile ColorNames.FooBar
end
