defmodule ExMangaDownloadr.MangaReader.ChapterPage do
  require Logger

  def pages(chapter_link) do
    Logger.debug("Fetching pages from chapter #{chapter_link}")
    case HTTPotion.get("http://www.mangareader.net#{chapter_link}", [timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
        { :ok, fetch_pages(body) }
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