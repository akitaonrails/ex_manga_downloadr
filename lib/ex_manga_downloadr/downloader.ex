defmodule ExMangaDownloadr.Downloader do
  @behaviour ExMangaDownloadr.Downloader.Behaviour
  @downloader Application.get_env(:ex_manga_downloadr, :downloader)

  alias ExMangaDownloadr.Cache
  alias HTTPoison.{Response, Error}

  @default_options %{
    max_retries: 50,
    retry_interval: 1_000,
    cache: ExMangaDownloadr.cache_handler(),
    cache_dir: ExMangaDownloadr.cache_dir()
  }

  def fetch_body(url, callback) do
    case call(url) do
      %Response{body: body, status_code: 200} ->
        {:ok, body |> callback.()}
    end
  end

  def call(url, options \\ []) do
    options = parse_options(options)
    call(url, options.max_retries, options)
  end

  defp parse_options(options) do
    @default_options
    |> Map.merge(options
    |> Enum.into(%{}))
  end

  def call(url, retries, options) when retries > 0 do
    cache_options = [dir: options.cache_dir, extractor: &(&1.body)]

    Cache.call options.cache, url, cache_options, fn
      :cache_hit, body -> to_success_response(body)
      :cache_miss, _ -> do_call(url, retries, options)
    end
  end

  defp to_success_response(body) do
    %Response{body: body, headers: [{"Content-Encoding", ""}], status_code: 200}
  end

  defp do_call(url, 0, options) do
    raise "Failed to fetch from #{url} after #{options.max_retries} retries."
  end

  defp do_call(url, retries, options) do
    try do
      @downloader.call(url) |> handle_response(url, retries, options)
    rescue
      error in Error -> error |> handle_response(url, retries, options)
    end
  end

  defp handle_response(%Response{status_code: status}, _, _, _) when status > 499 do
    raise %Error{reason: "req_timedout"}
  end

  defp handle_response(%Response{headers: headers, status_code: status}, _, retries, options)
       when status > 300 and status < 400 do
    url = List.keyfind(headers, "Location", 0) |> elem(1)
    do_call url, retries, options
  end

  defp handle_response(%Response{body: body, headers: headers, status_code: _} = resp, _, _, _) do
    %{resp | body: gunzip(body, headers)}
  end

  defp handle_response(%Error{}, url, retries, options) do
    :timer.sleep options.retry_interval
    do_call url, retries - 1, options
  end

  defp gunzip(body, headers) do
    if Enum.member?(headers, {"Content-Encoding", "gzip"}) do
      :zlib.gunzip(body)
    else
      body
    end
  end
end
