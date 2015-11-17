defmodule ExMangaDownloadr.ChapterPage do
  def pages(chapter_link) do
    case HTTPotion.get("http://www.mangareader.net#{chapter_link}", [timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
        { :ok, fetch_pages(body) }
      _ ->
        { :err, "not found"}
    end
  end

  defp fetch_pages(html) do
    Floki.find(html, "select[id='pageMenu'] option")
    |> Enum.map(fn line ->
         case line do
           {"option", [{"value", value}, {"selected", "selected"}], _} -> value
           {"option", [{"value", value}], _} -> value
         end
       end)
  end
end