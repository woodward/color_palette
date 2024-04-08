defmodule ColorNames do
  @moduledoc false

  defdelegate reset(), to: IO.ANSI
end
