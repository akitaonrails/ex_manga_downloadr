defmodule ExMangaDownloadr.Downloader do
  @max_retries  50
  @time_to_wait_to_fetch_again 1_000
  @user_agent   Application.get_env(:ex_manga_downloadr, :user_agent)
  @http_timeout 60_000

  def call(url, retries \\ @max_retries)
  def call(url, 0), do: raise "Failed to fetch from #{url} after #{@max_retries} retries."
  def call(url, retries) when retries > 0 do
    try do
      cache_path = "/tmp/ex_manga_downloadr_cache/#{cache_filename(url)}"
      response = if System.get_env("CACHE_HTTP") && File.exists?(cache_path) do
        {:ok, body} = File.read(cache_path)
        %HTTPoison.Response{ body: body, headers: [ "Content-Encoding": "" ], status_code: 200}
      else
        HTTPoison.get!(url, http_headers(), http_options())
      end
      case response do
        %HTTPoison.Response{ body: _, headers: _, status_code: status } when status > 499 ->
          raise %HTTPoison.Error{reason: "req_timedout"}
        %HTTPoison.Response{ body: _, headers: headers, status_code: status} when status > 300 and status < 400 ->
          call(List.keyfind(headers, "Location", 0) |> elem(1), retries)
        %HTTPoison.Response{ body: body, headers: headers, status_code: _ } ->
          if System.get_env("CACHE_HTTP") && !File.exists?(cache_path) do
            File.write!(cache_path, gunzip(body, headers))
          end
          %{response | body: gunzip(body, headers)}
        %HTTPoison.Error{} ->
            :timer.sleep(@time_to_wait_to_fetch_again)
            call(url, retries - 1)
          end
    rescue
      _ in HTTPoison.Error ->
              :timer.sleep(@time_to_wait_to_fetch_again)
              call(url, retries - 1)
    end
  end

  @doc """
  All HTTPoison.Response bodies should go through this gunzip process
  """
  def gunzip(body, headers) do
    if Enum.member?(headers, {"Content-Encoding", "gzip"}) do
      :zlib.gunzip(body)
    else
      body
    end
  end

  @doc """
  All HTTPoison requests should use this set of options
  """
  def http_headers do
    [{"User-Agent", @user_agent}, {"Accept-encoding", "gzip"}, {"Connection", "keep-alive"}]
  end

  def http_options do
    [timeout: @http_timeout]
  end

  defp cache_filename(url) do
    url
  end
end

