defmodule ExMangaDownloadr.Mangafox do
  @behaviour ExMangaDownloadr.MangaSource

  alias ExMangaDownloadr.Mangafox

  def applies?(url), do: ~r/mangafox\.me/ |> Regex.match?(url)
  def index_page(url), do: Mangafox.IndexPage.chapters(url)
  def chapter_page(url), do: Mangafox.ChapterPage.pages(url)
  def page_image(url), do: Mangafox.Page.image(url)
end
