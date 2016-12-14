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
      {"img", [{"src", image_src}, {"width", _}, {"id", "image"}, {"alt", _}], _} ->
        [ page_number | [ chapter_number | _ ] ] = page_link
          |> String.split("/")
          |> Enum.reverse

        page_number = page_number
          |> String.split(".")
          |> Enum.at(0)
          |> String.rjust(5, ?0)

        chapter_number = Regex.run(~r{[^\d]*([\d|\.]+$)}, chapter_number)
          |> Enum.reverse
          |> Enum.at(0)
          |> String.rjust(5, ?0)

        extension = image_src
          |> String.split("?")
          |> Enum.at(0)
          |> String.split(".")
          |> Enum.reverse
          |> Enum.at(0)

        {image_src, "#{chapter_number}-#{page_number}.#{extension}"}
      _ -> nil
    end
  end
end
