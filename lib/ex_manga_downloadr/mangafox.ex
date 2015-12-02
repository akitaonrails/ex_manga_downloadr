defmodule ExMangaDownloadr.Mangafox do
  defmacro __using__(_opts) do
    quote do
      alias ExMangaDownloadr.Mangafox.IndexPage
      alias ExMangaDownloadr.Mangafox.ChapterPage
      alias ExMangaDownloadr.Mangafox.Page
    end
  end

  def gunzip(body, headers) do
    if headers[:"Content-Encoding"] == "gzip" do
      :zlib.gunzip(body)
    else
      body
    end
  end
end