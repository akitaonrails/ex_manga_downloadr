defmodule ExMangaDownloadr do
  @user_agent Application.get_env(:ex_manga_downloadr, :user_agent)
  @http_timeout 60_000

  def gunzip(body, headers) do
    if headers[:"Content-Encoding"] == "gzip" do
      :zlib.gunzip(body)
    else
      body
    end
  end

  def http_headers do
    [
      headers: ["User-Agent": @user_agent, "Accept-encoding": "gzip"],
      timeout: @http_timeout
    ]
  end
end
