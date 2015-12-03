defmodule ExMangaDownloadr.MangaReader.IndexPage do
  def chapters(manga_root_url) do
    case HTTPotion.get(manga_root_url, ExMangaDownloadr.http_headers) do
      %HTTPotion.Response{ body: body, headers: headers, status_code: 200 } ->
        body = ExMangaDownloadr.gunzip(body, headers)
        {:ok, fetch_manga_title(body), fetch_chapters(body) }
      _ ->
        {:err, "not found"}
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