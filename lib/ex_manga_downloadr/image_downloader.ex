defmodule ImageDownloader do
  require Logger

  def call(image_data, directory) do
    download_image(image_data, directory)
  end

  defp download_image({image_src, image_filename}, directory) do
    filename = "#{directory}/#{image_filename}"
    if File.exists?(filename) do
      Logger.debug("Skipping image #{filename}; already downloaded.")
      {:ok, image_src, filename}
    else
      case ExMangaDownloadr.Downloader.call(image_src) do
        %HTTPoison.Response{ body: body, headers: _headers, status_code: 200 } ->
          File.write!(filename, body)
          {:ok, image_src, filename}
      end
    end
  end
end
