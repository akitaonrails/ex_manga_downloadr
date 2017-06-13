defmodule MangaWrapper do
  require Logger

  def index_page(url, source) do
    # this is not a wrapper to a handle_call but adding in the Worker because it is more relatable
    source
      |> manga_source("IndexPage")
      |> apply(:chapters, [url])
  end

  def chapter_page([chapter_link, source]) do
    source
      |> manga_source("ChapterPage")
      |> apply(:pages, [chapter_link])
  end

  def page_image([page_link, source]) do
    source
      |> manga_source("Page")
      |> apply(:image, [page_link])
  end

  def page_download_image(image_data, directory) do
    download_image(image_data, directory)
  end

  ## Helper functions

  defp manga_source(source, module) do
    case source do
      "mangareader" -> :"Elixir.ExMangaDownloadr.MangaReader.#{module}"
      "mangafox"    -> :"Elixir.ExMangaDownloadr.Mangafox.#{module}"
    end
  end

  defp download_image({image_src, image_filename}, directory) do
    filename = "#{directory}/#{image_filename}"
    if File.exists?(filename) do
      Logger.debug("Skipping image #{filename}; already downloaded.")
      {:ok, image_src, filename}
    else
      case ExMangaDownloadr.retryable_http_get(image_src) do
        %HTTPoison.Response{ body: body, headers: _headers, status_code: 200 } ->
          File.write!(filename, body)
          {:ok, image_src, filename}
      end
    end
  end
end
