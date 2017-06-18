defmodule ExMangaDownloadrTest.DownloaderTest do
  use ExUnit.Case
  alias ExMangaDownloadr.{Downloader, Cache}

  test "returns the response when it is 200" do
    response = Downloader.call("http://success200.com")

    assert response == %HTTPoison.Response{body: "fake", status_code: 200}
  end

  test "gunzips the response if applicable" do
    response = Downloader.call("http://gzip200ok.com")

    assert response == %HTTPoison.Response{
      body: "fake",
      status_code: 200,
      headers: [{"Content-Encoding", "gzip"}]
    }
  end

  test "redirects when response is 301" do
    response = Downloader.call("http://redirect301.com")

    assert response == %HTTPoison.Response{body: "fake", status_code: 200}
  end

  test "throws an error when response is 500" do
    url = "http://error500.com"
    message = "Failed to fetch from #{url} after 2 retries."

    assert_raise RuntimeError, message, fn ->
      Downloader.call url, max_retries: 2, retry_interval: 1
    end
  end

  test "throws an error when http library returns error" do
    url = "http://http_library_error.com"
    message = "Failed to fetch from #{url} after 2 retries."

    assert_raise RuntimeError, message, fn ->
      Downloader.call url, max_retries: 2, retry_interval: 1
    end
  end

  test "caches response if cache is enabled" do
    {:ok, tmpdir} = Briefly.create(directory: true)
    url = "http://success200.com"

    Downloader.call url, cache: :fs, cache_dir: tmpdir

    assert Cache.FS.read(url, dir: tmpdir) == "fake"
  end

  test "retrieves value from the cache if it exists" do
    url = "http://success200.com"
    {:ok, tmpdir} = Briefly.create(directory: true)
    Cache.FS.write(url, "cache_contents", dir: tmpdir)

    response = Downloader.call(url, cache: :fs, cache_dir: tmpdir)

    assert response == %HTTPoison.Response{
      body: "cache_contents",
      headers: [{"Content-Encoding", ""}],
      status_code: 200
    }
  end
end
