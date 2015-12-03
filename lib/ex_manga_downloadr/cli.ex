defmodule ExMangaDownloadr.CLI do
  alias ExMangaDownloadr.Workflow
  require ExMangaDownloadr

  def main(args) do
    args
    |> parse_args
    |> process
  end

  defp parse_args(args) do
    parse = OptionParser.parse(args,
      switches: [name: :string, url: :string, directory: :string, source: :string],
      aliases: [n: :name, u: :url, d: :directory, s: :source]
    )
    case parse do
      {[name: manga_name, url: url, directory: directory, source: source], _, _} -> process(manga_name, directory, {url, source})
      {[name: manga_name, directory: directory], _, _} -> process(manga_name, directory)
      {_, _, _ } -> process(:help)
    end
  end

  defp process(:help) do
    IO.puts """
      usage:
        ./ex_manga_downloadr -n boku-wa-ookami -u http://www.mangareader.net/boku-wa-ookami -d /tmp/boku-wa-ookami -s mangareader

      sources can be:
        - mangareader
        - mangafox

      or just to compile the PDFs (if already finished downloading)
        ./ex_manga_downloadr -n boku-wa-ookami -d /tmp/boku-wa-ookami

      as mangafox doesn't support too much concurrency optimize down like this:
        POOL_SIZE=10 ./ex_manga_downloadr -n onepunch -u http://mangafox.me/manga/onepunch_man/ -d /tmp/onepunch -s mangafox

      this tool optimizes to avoid doing every step again all the time, it saves a dump files in the provided directory to resume and it doesn't download images that already exists.
    """
    System.halt(0)
  end

  defp process(manga_name, directory, {_url, _source} = manga_site) do
    File.mkdir_p!(directory)

    images_list = 
      ExMangaDownloadr.managed_dump directory do
        manga_site
          |> Workflow.chapters
          |> Workflow.pages
          |> Workflow.images_sources 
      end

    images_list
      |> Workflow.process_downloads(directory)
      |> Workflow.optimize_images
      |> Workflow.compile_pdfs(manga_name)
      |> finish_process
  end

  defp process(manga_name, directory) do
    IO.puts "Just going to compile PDFs."

    directory
      |> Workflow.compile_pdfs(manga_name)
      |> finish_process
  end

  defp finish_process(directory) do
    IO.puts "Finished, please check your PDF files at #{directory}."
    System.halt(0)
  end
end
