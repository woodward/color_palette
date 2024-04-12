defmodule ColorPalette.ANSIColorCode do
  @moduledoc """
  ## ANSI Color Code Struct

  A struct which represents one of the 255 ANSI colors.
  """

  defstruct [:code, :hex, :rgb, :color_group]
end
