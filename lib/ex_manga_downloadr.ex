defmodule ExMangaDownloadr do
  def fetch(link, callback) do
    case ExMangaDownloadr.Downloader.call(link) do
      %HTTPoison.Response{ body: body, headers: headers, status_code: 200 } ->
        { :ok, body |> ExMangaDownloadr.Downloader.gunzip(headers) |> callback.() }
    end
  end
end
