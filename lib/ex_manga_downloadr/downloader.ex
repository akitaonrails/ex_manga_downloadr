defmodule ExMangaDownloadr.Downloader do
  @behaviour ExMangaDownloadr.Downloader.Behaviour
  @downloader Application.get_env(:ex_manga_downloadr, :downloader)

  def call(url) do
    url |> @downloader.call()
  end

  def fetch_body(url, callback) do
    case @downloader.call(url) do
      %HTTPoison.Response{body: body, status_code: 200} ->
        {:ok, body |> callback.()}
    end
  end
end
