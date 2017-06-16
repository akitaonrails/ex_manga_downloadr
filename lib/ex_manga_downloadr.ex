defmodule ExMangaDownloadr do
  @downloader Application.get_env(:ex_manga_downloadr, :downloader)

  def fetch(link, callback) do
    case @downloader.call(link) do
      %HTTPoison.Response{body: body, status_code: 200} ->
        {:ok, body |> callback.()}
    end
  end
end
