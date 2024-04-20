defmodule ColorPalette.ANSIColorCode do
  @moduledoc """
  ## ANSI Color Code Struct

  A struct which represents one of the 256 ANSI colors.
  """

  @type code :: 0..255
  @type rgb_value :: 0..255

  @type t :: %__MODULE__{
          code: code(),
          color_group: atom(),
          hex: String.t(),
          rgb: [rgb_value()]
        }

  defstruct [
    :code,
    :color_group,
    :hex,
    :rgb
  ]
end
