defmodule ExMangaDownloadr.Downloader.Mock do
  @behaviour ExMangaDownloadr.Downloader.Behaviour
  @fixtures_dir Path.join([File.cwd!, "test", "fixtures"])

  def call("http://src_foo") do
    %HTTPoison.Response{body: "fake_response", status_code: 200}
  end

  def call("http://mangafox.me/" <> path) do
    path
    |> fixture_dir("mangafox.me")
    |> read_fixture
  end

  def call("http://www.mangareader.net/" <> path) do
    path
    |> fixture_dir("mangareader.net")
    |> read_fixture
  end

  defp fixture_dir(path, base) do
    Path.join([@fixtures_dir, base, path])
  end

  defp read_fixture(path) do
    case File.read(path) do
      {:ok, body} -> %HTTPoison.Response{body: body, status_code: 200}
      _ -> raise "Could not find fixture #{path}"
    end
  end
end
