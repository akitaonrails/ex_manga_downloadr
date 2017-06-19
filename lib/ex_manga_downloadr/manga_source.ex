defmodule ExMangaDownloadr.MangaSource do
  def find(url) do
    case module_for(url) do
      :invalid -> :error
      module -> {:ok, module}
    end
  end

  defp module_for(url) do
    Application.get_env(:ex_manga_downloadr, :sources)
    |> Enum.find(:invalid, & &1.applies?(url))
  end
end
