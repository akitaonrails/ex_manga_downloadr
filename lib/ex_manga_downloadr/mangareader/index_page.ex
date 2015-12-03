defmodule ExMangaDownloadr.MangaReader.IndexPage do
  def chapters(manga_root_url) do
    case HTTPotion.get(manga_root_url, [timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
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