defmodule ExMangaDownloadr.Mangafox.ChapterPage do
  require Logger

  def pages(chapter_link) do
    Logger.debug("Fetching pages from chapter #{chapter_link}")
    case HTTPotion.get(chapter_link, ExMangaDownloadr.http_headers) do
      %HTTPotion.Response{ body: body, headers: headers, status_code: 200 } ->
        { :ok, body |> ExMangaDownloadr.gunzip(headers) |> fetch_pages(chapter_link) }
      _ ->
        { :err, "not found"}
    end
  end

  defp fetch_pages(html, chapter_link) do
    [_page|link_template] = chapter_link |> String.split("/") |> Enum.reverse

    html
    |> Floki.find("div[id='top_center_bar'] option")
    |> Floki.attribute("value")
    |> Enum.reject(fn page_number -> page_number == "0" end)
    |> Enum.map(fn page_number -> 
      ["#{page_number}.html"|link_template]
        |> Enum.reverse
        |> Enum.join("/")
    end)
  end
end