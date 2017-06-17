defmodule ExMangaDownloadr do
  def apply_env_options(list) do
    # Useful to limit downloads in end to end tests
    if System.get_env("LIST_LIMIT") do
      list |> Enum.slice(0, 2)
    else
      list
    end
  end
end
