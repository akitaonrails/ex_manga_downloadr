defmodule ExMangaDownloadr.MangaReader do
  @behaviour ExMangaDownloadr.MangaSource

  alias ExMangaDownloadr.MangaReader

  def applies?(url), do: ~r/mangareader\.net/ |> Regex.match?(url)
  def index_page(url), do: MangaReader.IndexPage.chapters(url)
  def chapter_page(url), do: MangaReader.ChapterPage.pages(url)
  def page_image(url), do: MangaReader.Page.image(url)
end
