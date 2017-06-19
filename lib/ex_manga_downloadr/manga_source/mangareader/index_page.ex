defmodule ExMangaDownloadr.MangaSource.MangaReader.IndexPage do
  def fetch_manga_title(html) do
    html
    |> Floki.find("#mangaproperties h1")
    |> Floki.text
  end

  def fetch_chapters(html) do
    html
    |> Floki.find("#listing a")
    |> Floki.attribute("href")
  end
end
