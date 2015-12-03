defmodule ExMangaDownloadr.MangaReader.Page do
  require Logger

  def image(page_link) do
    Logger.debug("Fetching image source from page #{page_link}")
    case HTTPotion.get("http://www.mangareader.net#{page_link}", [timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
        { :ok, fetch_image(body) }
      _ ->
        { :err, "not found"}
    end
  end

  defp fetch_image(html) do
    html
    |> Floki.find("div[id='imgholder'] img")
    |> Enum.map(&normalize_metadata/1)
    |> Enum.at(0)
  end

  defp normalize_metadata(line) do
    case line do
      {"img", [{"id", _}, {"width", _}, {"height", _}, {"src", image_src}, {"alt", image_alt}, {"name", "img"}], _} ->
        extension      = String.split(image_src, ".") |> Enum.at(-1)
        list           = String.split(image_alt)      |> Enum.reverse
        title_name     = Enum.slice(list, 4, Enum.count(list) - 1) |> Enum.join(" ")
        chapter_number = Enum.at(list, 3) |> String.rjust(5, ?0)
        page_number    = Enum.at(list, 0) |> String.rjust(5, ?0)

        {image_src, "#{title_name} #{chapter_number} - Page #{page_number}.#{extension}"}
      _ -> nil
    end

  end
end