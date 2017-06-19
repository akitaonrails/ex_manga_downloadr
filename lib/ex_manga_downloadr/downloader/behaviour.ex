defmodule ExMangaDownloadr.Downloader.Behaviour do
  @callback call(url :: String.t) :: %HTTPoison.Response{}
end
