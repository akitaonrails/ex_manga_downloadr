defmodule ExMangaDownloadr.MangaSource.Mangafox do
  @behaviour ExMangaDownloadr.MangaSource

  alias ExMangaDownloadr.Downloader
  import ExMangaDownloadr.MangaSource.Mangafox.{IndexPage, ChapterPage, Page}

  def applies?(url), do: ~r/mangafox\.me/ |> Regex.match?(url)

  def index_page(url) do
    Downloader.fetch_body(url, &{fetch_manga_title(&1), fetch_chapters(&1)})
  end

  def chapter_page(url) do
    Downloader.fetch_body(url, &fetch_pages(&1, url))
  end

  def page_image(url) do
    Downloader.fetch_body(url, &fetch_image(&1, url))
  end
end
