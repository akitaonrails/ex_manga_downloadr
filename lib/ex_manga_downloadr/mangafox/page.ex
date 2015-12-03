defmodule ExMangaDownloadr.Mangafox.Page do
  require Logger
  require ExMangaDownloadr

  def image(page_link) do
    ExMangaDownloadr.fetch page_link, do: fetch_image(page_link)
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