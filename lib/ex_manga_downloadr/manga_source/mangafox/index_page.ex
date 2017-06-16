defmodule ExMangaDownloadr.MangaSource.Mangafox.IndexPage do
  def fetch_manga_title(html) do
    html
    |> Floki.find("h1")
    |> Floki.text
  end

  def fetch_chapters(html) do
    html
    |> Floki.find(".chlist a[class='tips']")
    |> Floki.attribute("href")
  end
end
