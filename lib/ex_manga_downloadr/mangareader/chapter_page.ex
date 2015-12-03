defmodule ExMangaDownloadr.MangaReader.ChapterPage do
  require Logger

  def pages(chapter_link) do
    Logger.debug("Fetching pages from chapter #{chapter_link}")
    case HTTPotion.get("http://www.mangareader.net#{chapter_link}", ExMangaDownloadr.http_headers) do
      %HTTPotion.Response{ body: body, headers: headers, status_code: 200 } ->
        { :ok, body |> ExMangaDownloadr.gunzip(headers) |> fetch_pages }
      _ ->
        { :err, "not found"}
    end
  end

  defp fetch_pages(html) do
    html
    |> Floki.find("select[id='pageMenu'] option")
    |> Floki.attribute("value")
  end
end