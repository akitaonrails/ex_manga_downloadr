defmodule ExMangaDownloadr.Downloader do
  @callback call(String.t) :: %HTTPoison.Response{}
end
