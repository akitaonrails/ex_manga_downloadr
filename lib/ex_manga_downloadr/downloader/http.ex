defmodule ExMangaDownloadr.Downloader.HTTP do
  @behaviour ExMangaDownloadr.Downloader.Behaviour
  @user_agent Application.get_env(:ex_manga_downloadr, :user_agent)
  @http_timeout 60_000

  def call(url) do
    HTTPoison.get!(url, http_headers(), http_options())
  end

  defp http_headers do
    [{"User-Agent", @user_agent}, {"Accept-encoding", "gzip"}, {"Connection", "keep-alive"}]
  end

  defp http_options do
    [timeout: @http_timeout]
  end
end
