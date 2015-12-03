defmodule ExMangaDownloadr.Mangafox.ChapterPage do
  require Logger

  @user_agent Application.get_env(:ex_manga_downloadr, :user_agent)

  def pages(chapter_link) do
    Logger.debug("Fetching pages from chapter #{chapter_link}")
    case HTTPotion.get(chapter_link, [headers: ["User-Agent": @user_agent, "Accept-encoding": "gzip"], timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: headers, status_code: 200 } ->
        body = ExMangaDownloadr.gunzip(body, headers)
        { :ok, fetch_pages(chapter_link, body) }
      _ ->
        { :err, "not found"}
    end
  end

  defp fetch_pages(chapter_link, html) do
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