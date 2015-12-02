defmodule ExMangaDownloadr.Mangafox.IndexPage do

  @user_agent Application.get_env(:ex_manga_downloadr, :user_agent)

  def chapters(manga_root_url) do
    case HTTPotion.get(manga_root_url, [
      headers: ["User-Agent": @user_agent, "Accept-encoding": "gzip"], timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: headers, status_code: 200 } ->
        body = ExMangaDownloadr.Mangafox.gunzip(body, headers)
        {:ok, fetch_manga_title(body), fetch_chapters(body) }
      _ ->
        {:err, "not found"}
    end
  end

  defp fetch_manga_title(html) do
    html
    |> Floki.find("h1")
    |> Enum.map(fn {"h1", [{"style", _}], [title]} -> title end)
    |> Enum.at(0)
  end

  defp fetch_chapters(html) do
    html
    |> Floki.find(".chlist a[class='tips']")
    |> Enum.map fn {"a", [{"href", url}, {"title", _}, {"class", "tips"}], _} -> url end
  end
end