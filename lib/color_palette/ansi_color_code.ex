defmodule ColorPalette.ANSIColorCode do
  @moduledoc """
  ## ANSI Color Code Struct

  A struct which represents one of the 256 ANSI colors.
  """
  alias ColorPalette.ColorGroup

  @type code :: 0..255
  @type rgb_value :: 0..255
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
