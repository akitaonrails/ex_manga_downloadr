defmodule ExMangaDownloadr.Workflow do
  require Logger
  alias ExMangaDownloadr.MangaSource

  defexception message: nil

  @max_demand             100 # maximum parallel HTTP GET batch
  @download_timeout       30000 # 30 seconds for download timeout
  @image_dimensions       "600x800" # Kindle maximum resolution
  @pages_per_volume       250       # comfortable PDF file number of pages
  @await_timeout_ms       1_000_000 # has to wait for huge number of async Tasks at once
  @maximum_pdf_generation 2 # the best value is probably the total number of CPU cores

  def determine_source(url) do
    case ExMangaDownloadr.MangaSource.for(url) do
      {:ok, module} -> {url, module}
      :error -> raise __MODULE__, message: "Unable to determine the manga source, URL invalid."
    end
  end

  def chapters({url, module}) do
    {:ok, {_manga_title, chapter_list}} = module.index_page(url)

    {chapter_list, module}
  end

  def pages({chapter_list, module}) do
    pages_list = chapter_list
      |> Task.async_stream(module, :chapter_page, [], max_concurrency: @max_demand)
      |> Enum.to_list()
      |> Enum.reduce([], fn {:ok, {:ok, list}}, acc -> acc ++ list end)
    {pages_list, module}
  end

  def images_sources({pages_list, module}) do
    pages_list
      |> Task.async_stream(module, :page_image, [], max_concurrency: @max_demand)
      |> Enum.to_list()
      |> Enum.map(fn {:ok, {:ok, image}} -> image end)
  end

  def process_downloads(images_list, directory) do
    images_list
      |> Task.async_stream(ImageDownloader, :call, [directory], max_concurrency: @max_demand / 2, timeout: @download_timeout)
      |> Enum.to_list()
    directory
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
      |> Enum.map(&("#{directory}/#{&1}"))
      |> chunk(@pages_per_volume)
      |> Enum.with_index
      |> chunk(@maximum_pdf_generation)
      |> Enum.map(fn batch ->
        batch
          |> Enum.map(&(compile_volume(manga_name, directory, &1)))
          |> Enum.map(&(Task.await(&1, @await_timeout_ms)))
      end)

    directory
  end

  defp compile_volume(manga_name, directory, {chunk, index}) do
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
