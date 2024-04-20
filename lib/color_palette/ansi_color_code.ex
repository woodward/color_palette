defmodule ColorPalette.ANSIColorCode do
  @moduledoc """
  ## ANSI Color Code Struct

  A struct which represents one of the 256 ANSI colors.
  """
  alias ColorPalette.ColorGroup

  # An integer in the range 0 - 255:
  @type code :: integer()

  # An integer in the range 0 - 255:
  @type rgb_value :: integer()

  @type hex :: String.t()

  @type t :: %__MODULE__{
          code: code(),
          color_group: ColorGroup.t(),
          hex: hex(),
          rgb: [rgb_value()]
        }

  defstruct [
    :code,
    :color_group,
    :hex,
    :rgb
  ]
end
