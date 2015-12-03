defmodule ExMangaDownloadr.MangaReader.ChapterPage do
  require Logger
  require ExMangaDownloadr

  def pages(chapter_link) do
    ExMangaDownloadr.fetch "http://www.mangareader.net#{chapter_link}", do: fetch_pages
  end

  defp fetch_pages(html) do
    html
    |> Floki.find("select[id='pageMenu'] option")
    |> Floki.attribute("value")
  end
end