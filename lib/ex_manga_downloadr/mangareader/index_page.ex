defmodule ExMangaDownloadr.MangaReader.IndexPage do
  require Logger
  require ExMangaDownloadr

  def chapters(manga_root_url) do
    ExMangaDownloadr.fetch manga_root_url, fn html ->
      {fetch_manga_title(html), fetch_chapters(html)}
    end
  end

  defp fetch_manga_title(html) do
    html
    |> Floki.find("#mangaproperties h1")
    |> Floki.text
  end

  defp fetch_chapters(html) do
    html
    |> Floki.find("#listing a")
    |> Floki.attribute("href")
  end
end