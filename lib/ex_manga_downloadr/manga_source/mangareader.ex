defmodule ExMangaDownloadr.MangaSource.MangaReader do
  alias ExMangaDownloadr.{MangaSource, Downloader}
  import MangaSource.MangaReader.{IndexPage, ChapterPage, Page}

  @behaviour MangaSource.Behaviour

  def applies?(url), do: ~r/mangareader\.net/ |> Regex.match?(url)

  def index_page(url) do
    Downloader.fetch_body(url, &{fetch_manga_title(&1), fetch_chapters(&1)})
  end

  def chapter_page(chapter_path) do
    chapter_path
    |> fetch_path_body(&fetch_pages/1)
  end

  def page_image(page_path) do
    page_path
    |> fetch_path_body(&fetch_image/1)
  end

  defp fetch_path_body(path, cb) do
    "http://www.mangareader.net#{path}"
    |> Downloader.fetch_body(cb)
  end
end
