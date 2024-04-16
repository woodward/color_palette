defmodule Mix.Tasks.GenerateGuides do
  use Mix.Task

  @shortdoc "Generates the Color Groups and ANSI Color Codes guides"

  alias ColorPalette.GuideGenerator

  def run(_args) do
    start_app!()
    GuideGenerator.generate_color_groups_guide()
    GuideGenerator.generate_ansi_color_codes_guide()
  end

  defp start_app!, do: Mix.Task.run("app.start", [])
end
