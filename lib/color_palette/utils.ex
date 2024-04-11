defmodule ColorPalette.Utils do
  @moduledoc false

  def read_json_file!(filename), do: filename |> File.read!() |> Jason.decode!(keys: :atoms)
end
