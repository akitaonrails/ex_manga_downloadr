defmodule ExMangaDownloadr.Mangafox do
  defmacro __using__(_opts) do
    quote do
      alias ExMangaDownloadr.Mangafox.IndexPage
      alias ExMangaDownloadr.Mangafox.ChapterPage
      alias ExMangaDownloadr.Mangafox.Page
    end
  end
end