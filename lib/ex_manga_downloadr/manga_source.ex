defmodule ExMangaDownloadr.MangaSource do
  def find(url) do
    case module_for(url) do
      :invalid -> :error
      module -> {:ok, module}
    end
  end

  defp module_for(url) do
    :ex_manga_downloadr
    |> Application.get_env(:sources)
    |> Enum.find(:invalid, & &1.applies?(url))
  end
end
