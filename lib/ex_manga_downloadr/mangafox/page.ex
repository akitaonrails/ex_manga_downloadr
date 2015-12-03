defmodule ExMangaDownloadr.Mangafox.Page do
  require Logger

  def image(page_link) do
    Logger.debug("Fetching image source from page #{page_link}")
    case HTTPotion.get(page_link, ExMangaDownloadr.http_headers) do
      %HTTPotion.Response{ body: body, headers: headers, status_code: 200 } ->
        { :ok, body |> ExMangaDownloadr.gunzip(headers) |> fetch_image(page_link) }
      _ ->
        { :err, "not found"}
    end
  end

  defp fetch_image(html, page_link) do
    html
    |> Floki.find("div[class='read_img'] img")
    |> Enum.map(&normalize_metadata(&1, page_link))
    |> Enum.at(0)
  end

  defp normalize_metadata(line, page_link) do
    case line do
      {"img", [{"src", image_src}, {"onerror", _}, {"width", _}, {"id", "image"}, {"alt", _}], _} ->
        extension = image_src |> String.split(".") |> Enum.reverse |> Enum.at(0)
        tokens    = page_link |> String.split("/") |> Enum.reverse
        filename  = Enum.at(tokens, 0) |> String.split(".") |> Enum.at(0) |> String.rjust(5, ?0)

        {image_src, "#{Enum.at(tokens, 2)}-#{Enum.at(tokens, 1)}-#{filename}.#{extension}"}
      _ -> nil
    end
  end
end