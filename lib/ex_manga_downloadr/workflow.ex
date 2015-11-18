defmodule ExMangaDownloadr.Workflow do
  use ExMangaDownloadr.MangaReader
  require Logger

  @image_dimensions "600x800"
  @pages_per_volume 250
  @maximum_fetches 80
  @maximum_pdf_generation 4

  def chapters(url) do
    {:ok, _manga_title, chapter_list} = IndexPage.chapters(url)
    chapter_list
  end

  def pages(chapter_list) do
    chapter_list
      |> Enum.map(&(Task.async(fn -> ChapterPage.pages(&1) end)))
      |> Enum.map(&(Task.await(&1, 30_000)))
      |> Enum.reduce([], fn {:ok, list}, acc -> acc ++ list end)
  end

  def images_sources(pages_list) do
    pages_list
      |> chunk(@maximum_fetches)
      |> Enum.reduce([], fn pages_chunk, acc ->
        result = pages_chunk
          |> Enum.map(&(Task.async(fn -> Page.image(&1) end)))
          |> Enum.map(&(Task.await(&1, 30_000)))
          |> Enum.map(fn {:ok, image} -> image end)
        acc ++ result
      end)
  end

  def process_downloads(images_list, directory) do
    images_list
      |> chunk(@maximum_fetches)
      |> Enum.reduce([], fn images_chunk, acc ->
        result = images_chunk
          |> Enum.map(fn {image_src, image_filename} ->
            Task.async(fn -> download_image(image_src, image_filename, directory) end)
          end)
          |> Enum.map(&(Task.await(&1, 30_000)))
        acc ++ result
      end)
  end

  def optimize_images(directory) do
    Logger.debug("Running mogrify to convert all images down to Kindle supported size (600x800)")
    Porcelain.shell("mogrify -resize #{@image_dimensions} #{directory}/*.jpg")
    directory
  end

  defp download_image(image_src, image_filename, directory) do
    filename = "#{directory}/#{image_filename}"
    Logger.debug("Downloading image #{image_src} to #{filename}")
    case HTTPotion.get(image_src, [timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
        File.write!(filename, body)
        {:ok, image_src, filename}
      _ ->
        {:err, image_src}
    end
  end

  def compile_pdfs(directory, manga_name) do
    {:ok, final_files_list} = File.ls(directory)

    final_files_list
      |> Enum.sort
      |> Enum.map(&("#{directory}/#{&1}"))
      |> chunk(@pages_per_volume)
      |> Enum.with_index
      |> chunk(@maximum_pdf_generation)
      |> Enum.map(fn batch -> 
        batch
          |> Enum.map(fn {chunk, index} ->
            compile_volume(manga_name, directory, chunk, index)
          end)
          |> Enum.map(&(Task.await(&1, 300_000)))
      end)
      
    directory
  end

  defp compile_volume(manga_name, directory, chunk, index) do
    {:ok, convert_cmd} = prepare_volume(manga_name, directory, chunk, index)
    Logger.debug "Compiling volume #{index + 1}."
    Task.async(fn -> Porcelain.shell(convert_cmd) end)
  end

  defp prepare_volume(manga_name, directory, chunk, index) do
    volume_directory = "#{directory}/#{manga_name}_#{index + 1}"
    volume_file      = "#{volume_directory}.pdf"
    File.mkdir_p(volume_directory)

    Enum.each(chunk, fn file ->
      [destination_file|_rest] = String.split(file, "/") |> Enum.reverse
      File.rename(file, "#{volume_directory}/#{destination_file}")
    end)

    {:ok, "convert #{volume_directory}/*.jpg #{volume_file}"}
  end

  defp chunk(collection, default_size) do
    size = [Enum.count(collection), default_size] |> Enum.min
    Enum.chunk(collection, size, size, [])
  end
end
