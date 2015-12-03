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
