defmodule ExMangaDownloadr.CLI do
  alias ExMangaDownloadr.IndexPage
  alias ExMangaDownloadr.ChapterPage
  alias ExMangaDownloadr.Page

  def main(args) do
    args
    |> parse_args
    |> process
  end

  defp parse_args(args) do
    parse = OptionParser.parse(args,
      switches: [url: :string, directory: :string],
      aliases: [u: :url, d: :directory]  
    )
    case parse do
      {[url: url, directory: directory], _, _} -> process(url, directory)
      {_, _, _ } -> process(:help)
    end
  end

  defp process(:help) do
    IO.puts """
      usage: ./ex_manga_downloadr -u http://www.mangareader.net/boku-wa-ookami -d /tmp/boku-wa-ookami
    """
    System.halt(0)
  end

  defp process(url, directory) do
    IO.puts "Fetching from #{url}"
    IO.puts "Creating directory: #{directory}"
    File.mkdir_p!(directory)

    # fetch all chapters
    {:ok, manga_title, chapter_list} = IndexPage.chapters(url)

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
            # download_image(image_src, image_filename, directory)

          end)
        end)
        |> Enum.map(fn pid -> Task.await(pid, 30_000) end)
      end)

    download_results
    |> Enum.reduce(fn list, acc -> list ++ acc end)
    |> Enum.each(fn result -> 
      case result do
        {:err, image_src} -> IO.puts("Error downloading #{image_src}")
        :ok -> result
      end
    end)

    IO.puts "Successfully finished fetching image to directory #{directory}."
    System.halt(0)
  end

  defp download_image(image_src, image_filename, directory) do
    case HTTPoison.get(image_src, [timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
        File.write!("#{directory}/#{image_filename}", body)
        :ok
      _ ->
        {:err, image_src}
    end
  end
end