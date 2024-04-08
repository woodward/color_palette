defmodule ColorPalette do
  @moduledoc false

  defdelegate reset(), to: IO.ANSI

  @before_compile ColorPalette.FooBar

  def add_code_to_color_data(ansi_codes, color_data) do
    Enum.zip(ansi_codes, color_data)
    |> Enum.map(fn {ansi_code, color_datum} ->
      Map.merge(color_datum, %{ansi_code: ansi_code.code})
    end)
  end
end
