defmodule ExMangaDownloadr.MangaReader do
  defmacro __using__(_opts) do
    quote do
      alias ExMangaDownloadr.MangaReader.IndexPage
      alias ExMangaDownloadr.MangaReader.ChapterPage
      alias ExMangaDownloadr.MangaReader.Page
    end
  end
end