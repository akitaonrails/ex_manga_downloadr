defmodule ExMangaDownloadr.MangaReader.ChapterPage do
  require Logger
  require ExMangaDownloadr

  def pages(chapter_link) do
    ExMangaDownloadr.fetch "http://www.mangareader.net#{chapter_link}", &fetch_pages/1
  end

  defp fetch_pages(html) do
    html
    |> Floki.find("select[id='pageMenu'] option")
    |> Floki.attribute("value")
  end
end