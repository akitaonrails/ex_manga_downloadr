defmodule ExMangaDownloadr.Downloader.Behaviour do
  @callback call(String.t) :: %HTTPoison.Response{}
end
