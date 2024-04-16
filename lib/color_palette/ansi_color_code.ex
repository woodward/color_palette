defmodule ColorPalette.ANSIColorCode do
  @moduledoc """
  ## ANSI Color Code Struct

  A struct which represents one of the 256 ANSI colors.
  """

  defstruct [
    :code,
    :color_group,
    :hex,
    :rgb
  ]
end
