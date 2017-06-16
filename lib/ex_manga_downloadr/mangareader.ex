defmodule ExMangaDownloadr.MangaReader do
  @behaviour ExMangaDownloadr.MangaSource

  import ExMangaDownloadr.MangaReader.{IndexPage, ChapterPage, Page}

  def applies?(url), do: ~r/mangareader\.net/ |> Regex.match?(url)

  def index_page(url) do
    ExMangaDownloadr.fetch url, &{fetch_manga_title(&1), fetch_chapters(&1)}
  end

  def chapter_page(chapter_path) do
    chapter_path
    |> to_url
    |> ExMangaDownloadr.fetch(&fetch_pages/1)
  end

  def page_image(page_path) do
    page_path
    |> to_url
    |> ExMangaDownloadr.fetch(&fetch_image/1)
  end

  defp to_url(path) do
    "http://www.mangareader.net#{path}"
  end
end
