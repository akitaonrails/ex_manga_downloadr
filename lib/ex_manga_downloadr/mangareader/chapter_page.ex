defmodule ExMangaDownloadr.MangaReader.ChapterPage do
  def fetch_pages(html) do
    html
    |> Floki.find("select[id='pageMenu'] option")
    |> Floki.attribute("value")
  end
end