defmodule ExMangaDownloadr.Workflow do
  alias ExMangaDownloadr.IndexPage
  alias ExMangaDownloadr.ChapterPage
  alias ExMangaDownloadr.Page
  alias Porcelain.Result
  require Logger

  @image_dimensions "600x800"
  @pages_per_volume 250

  def chapters(url) do
    {:ok, _manga_title, chapter_list} = IndexPage.chapters(url)
    chapter_list
  end

  def pages(chapter_list) do
    chapter_list
      |> Enum.map(fn chapter_page ->
        Task.async(fn ->
          Logger.debug("Fetching pages from chapter #{chapter_page}")
          ChapterPage.pages(chapter_page)
        end)
      end)
      |> Enum.map(fn pid -> Task.await(pid, 30_000) end)
  end

  def images_sources(pages_group) do
    pages_group
      |> Enum.map(fn {:ok, pages_list} ->
        pages_list
        |> Enum.map(fn page ->
          Task.async(fn ->
            Logger.debug("Fetching image source from page #{page}")
            Page.image(page)
          end)
        end)
        |> Enum.map(fn pid -> Task.await(pid, 30_000) end)
      end)
  end

  def process_downloads(images_group, directory) do
    images_group
      |> Enum.map(fn images_list ->
        images_list
        |> Enum.map(fn {:ok, {image_src, image_filename}} ->
          Task.async(fn ->
            Logger.debug("Downloading image #{image_src} to #{image_filename}")
            download_image(image_src, image_filename, directory)
          end)
        end)
        |> Enum.map(fn pid -> Task.await(pid, 30_000) end)
      end)
  end

  def optimize_images(directory) do
    Logger.debug("Running mogrify to convert all images down to Kindle supported size (600x800)")
    Porcelain.shell("mogrify -resize #{@image_dimensions} #{directory}/*.jpg")
    directory
  end

  def compile_pdfs(directory, manga_name) do
    {:ok, final_files_list} = File.ls(directory)
    final_files_list
    |> Enum.sort
    |> Enum.map(fn filename -> "#{directory}/#{filename}" end)
    |> Enum.chunk(chunk_size(final_files_list))
    |> Enum.with_index
    |> Enum.map(fn {chunk, index} -> creating_volume(manga_name, directory, chunk, index) end)
    |> Enum.map(fn pid -> Task.await(pid, 300_000) end)
  end

  defp download_image(image_src, image_filename, directory) do
    case HTTPotion.get(image_src, [timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
        filename = "#{directory}/#{image_filename}"
        File.write!(filename, body)
        {:ok, image_src, filename}
      _ ->
        {:err, image_src}
    end
  end

  defp chunk_size(final_files_list) do
    result = length(final_files_list)
    if result > @pages_per_volume do
      result = @pages_per_volume
    end
    result
  end

  defp creating_volume(manga_name, directory, chunk, index) do
    volume_directory = "#{directory}/#{manga_name}_#{index + 1}"
    volume_file      = "#{volume_directory}.pdf"
    File.mkdir_p(volume_directory)
    chunk
      |> Enum.each(fn file ->
        [destination_file|_rest] = String.split(file, "/") |> Enum.reverse
        File.rename(file, "#{volume_directory}/#{destination_file}")
      end)
    Logger.debug("Compiling #{volume_file}.")
    Task.async(fn ->
      Porcelain.shell("convert #{volume_directory}/*.jpg #{volume_file}")
    end)
  end
end
