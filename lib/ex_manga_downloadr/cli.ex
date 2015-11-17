defmodule ExMangaDownloadr.CLI do
  alias ExMangaDownloadr.IndexPage
  alias ExMangaDownloadr.ChapterPage
  alias ExMangaDownloadr.Page
  alias Porcelain.Result

  @pages_per_volume 250

  def main(args) do
    args
    |> parse_args
    |> process
  end

  defp parse_args(args) do
    parse = OptionParser.parse(args,
      switches: [name: :string, url: :string, directory: :string],
      aliases: [n: :name, u: :url, d: :directory]  
    )
    case parse do
      {[name: manga_name, url: url, directory: directory], _, _} -> process(manga_name, url, directory)
      {_, _, _ } -> process(:help)
    end
  end

  defp process(:help) do
    IO.puts """
      usage: ./ex_manga_downloadr -name boku-wa-ookami -u http://www.mangareader.net/boku-wa-ookami -d /tmp/boku-wa-ookami
    """
    System.halt(0)
  end

  defp process(manga_name, url, directory) do
    IO.puts "Fetching from #{url}"
    IO.puts "Creating directory: #{directory}"
    File.mkdir_p!(directory)

    # fetch all chapters
    {:ok, _manga_title, chapter_list} = IndexPage.chapters(url)

    pages_group = chapter_list
      |> Enum.map(fn chapter_page ->
        Task.async(fn ->
          IO.puts("Fetching pages from chapter #{chapter_page}")
          ChapterPage.pages(chapter_page)
        end)
      end)
      |> Enum.map(fn pid -> Task.await(pid, 30_000) end)

    images_group = pages_group
      |> Enum.map(fn {:ok, pages_list} ->
        pages_list
        |> Enum.map(fn page -> 
          Task.async(fn -> 
            IO.puts("Fetching image source from page #{page}")
            Page.image(page)
          end)
        end)
        |> Enum.map(fn pid -> Task.await(pid, 30_000) end)
      end)

    download_results = images_group
      |> Enum.map(fn images_list ->
        images_list
        |> Enum.map(fn {:ok, {image_src, image_filename}} ->
          Task.async(fn -> 
            IO.puts "Downloading image #{image_src} to #{image_filename}"
            download_image(image_src, image_filename, directory)
          end)
        end)
        |> Enum.map(fn pid -> Task.await(pid, 30_000) end)
      end)

    image_files_list = download_results
      |> Enum.reduce(fn list, acc -> list ++ acc end)
      |> Enum.map(fn result -> 
        case result do
          {:err, image_src} ->
            IO.puts("Error downloading #{image_src}")
            nil
          {:ok, _image_src, filename} -> filename
        end
      end)
      |> Enum.reject(fn result -> result == nil end)

    IO.puts "Successfully finished fetching image to directory #{directory}."

    IO.puts "Running mogrify to convert all images down to Kindle supported size (600x800)"
    %Result{out: _output, status: _status} = Porcelain.shell("mogrify -resize 600x800 #{directory}/*.jpg")

    image_files_list
    |> Enum.chunk(@pages_per_volume)
    |> Enum.with_index
    |> Enum.map(fn {chunk, index} -> creating_volume(manga_name, directory, chunk, index) end)
    |> Enum.map(fn pid -> Task.await(pid, 300_000) end)

    System.halt(0)
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
    IO.puts "Compiling #{volume_file}."
    Task.async(fn ->
      %Result{out: _output, status: _status} = Porcelain.shell("convert #{volume_directory}/*.jpg #{volume_file}")
    end)    
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
end