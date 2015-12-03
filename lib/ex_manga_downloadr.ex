defmodule ExMangaDownloadr do
  @user_agent   Application.get_env(:ex_manga_downloadr, :user_agent)
  @http_timeout 60_000

  @doc """
  All HTTPotion.Response bodies should go through this gunzip process
  """
  def gunzip(body, headers) do
    if headers[:"Content-Encoding"] == "gzip" do
      :zlib.gunzip(body)
    else
      body
    end
  end

  @doc """
  All HTTPotion requests should use this set of options
  """
  def http_headers do
    [
      headers: ["User-Agent": @user_agent, "Accept-encoding": "gzip"],
      timeout: @http_timeout
    ]
  end

  @doc """
  Loads a dump of the last images list saved, otherwise go through the
  unquote(expression) for the lengthy process of fetching this list and
  then saving the dump, to be used to resume the work later
  """
  defmacro managed_dump(directory, do: expression) do
    quote do
      dump_file = "#{unquote(directory)}/images_list.dump"
      images_list = if File.exists?(dump_file) do
          :erlang.binary_to_term(File.read!(dump_file))
        else
          list = unquote(expression)
          File.write(dump_file, :erlang.term_to_binary(list))
          list
        end
    end
  end

  defmacro fetch(link, do: expression) do
    quote do
      Logger.debug("Fetching from #{unquote(link)}")
      case HTTPotion.get(unquote(link), ExMangaDownloadr.http_headers) do
        %HTTPotion.Response{ body: body, headers: headers, status_code: 200 } ->
          { :ok, body |> ExMangaDownloadr.gunzip(headers) |> unquote(expression) }
        _ ->
          { :err, "not found"}
      end
    end
  end

  ## Phoenix like "use ExMangaDownloadr, :mangareader" for aliasing

  def mangareader do
    quote do
      alias ExMangaDownloadr.MangaReader.IndexPage
      alias ExMangaDownloadr.MangaReader.ChapterPage
      alias ExMangaDownloadr.MangaReader.Page
    end
  end

  def mangafox do
    quote do
      alias ExMangaDownloadr.Mangafox.IndexPage
      alias ExMangaDownloadr.Mangafox.ChapterPage
      alias ExMangaDownloadr.Mangafox.Page
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
