defmodule ExMangaDownloadr.MangaSource.Mangafox do
  @behaviour ExMangaDownloadr.MangaSource

  import ExMangaDownloadr.MangaSource.Mangafox.{IndexPage, ChapterPage, Page}

  def applies?(url), do: ~r/mangafox\.me/ |> Regex.match?(url)

  def index_page(url) do
    ExMangaDownloadr.fetch url, &{fetch_manga_title(&1), fetch_chapters(&1)}
  end

  def chapter_page(url) do
    ExMangaDownloadr.fetch url, &fetch_pages(&1, url)
  end

  def page_image(url) do
    ExMangaDownloadr.fetch url, &fetch_image(&1, url)
  end
end
