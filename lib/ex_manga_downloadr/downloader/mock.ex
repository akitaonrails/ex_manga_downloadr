defmodule ExMangaDownloadr.Fixture do
  @fixtures_dir Path.join([File.cwd!, "test", "fixtures"])

  def read(path, base) do
    case path |> dir(base) |> File.read() do
      {:ok, body} -> body
      _ -> raise "Could not find fixture #{path}"
    end
  end

  defp dir(path, base) do
    Path.join([@fixtures_dir, base, path])
  end
end

defmodule ExMangaDownloadr.Downloader.Mock do
  @behaviour ExMangaDownloadr.Downloader.Behaviour

  alias HTTPoison.{Response, Error}
  alias ExMangaDownloadr.Fixture

  def call("http://success200.com") do
    %Response{body: "fake", status_code: 200}
  end

  def call("http://mangafox.me/" <> path) do
    path
    |> Fixture.read("mangafox.me")
    |> to_success_response()
  end

  def call("http://www.mangareader.net/" <> path) do
    path
    |> Fixture.read("mangareader.net")
    |> to_success_response()
  end

  def call("http://error500.com") do
    %Response{status_code: 500}
  end

  def call("http://redirect301.com") do
    %Response{status_code: 301, headers: [{"Location", "http://success200.com"}]}
  end

  def call("http://gzip200ok.com") do
    %Response{
      status_code: 200,
      body: :zlib.gzip("fake"),
      headers: [{"Content-Encoding", "gzip"}]
    }
  end

  def call("http://http_library_error.com") do
    %Error{}
  end

  def to_success_response(body) do
    %Response{body: body, status_code: 200}
  end
end
