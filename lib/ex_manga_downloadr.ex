defmodule ExMangaDownloadr do
  def fetch(link, callback) do
    case ExMangaDownloadr.Downloader.call(link) do
      %HTTPoison.Response{ body: body, status_code: 200 } ->
        { :ok, body |> callback.() }
    end
  end
end
