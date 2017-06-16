defmodule ExMangaDownloadrTest do
  use ExUnit.Case, async: false
  doctest ExMangaDownloadr
  alias ExMangaDownloadr.Workflow

  import Mock

  @module ExMangaDownloadr.MangaSource.FakeMangaSource.Fake

  test "workflow fetches chapters" do
    chapters_list = {"http://foo.com/bar", @module} |> Workflow.chapters()

    assert chapters_list == {@module.expected_chapters(), @module}
  end

  test "workflow fetches pages from chapters" do
    pages_list = {["foo"], @module} |> Workflow.pages()

    assert pages_list == {@module.expected_pages(), @module}
  end

  test "workflow fetches image sources from pages" do
    images_list = {["foo"], @module} |> Workflow.images_sources()

    assert images_list == [@module.expected_image()]
  end

  test "workflow tries to download the images" do
    with_mock HTTPoison,
      [get!: fn(_url, _headers, _options) -> %HTTPoison.Response{ body: nil, headers: nil, status_code: 200 } end] do
      with_mock File, [write!: fn(_filename, _body) -> nil end,
                       exists?: fn(_filename) -> false end] do
        assert Workflow.process_downloads([{"http://src_foo", "filename_foo"}], "/tmp") == "/tmp"

        assert called HTTPoison.get!("http://src_foo", ExMangaDownloadr.Downloader.http_headers, ExMangaDownloadr.Downloader.http_options)
        assert called File.write!("/tmp/filename_foo", nil)
      end
    end
  end

  test "workflow skips existing images" do
    with_mock File, [exists?: fn(_filename) -> true end] do
      assert Workflow.process_downloads([{"http://src_foo", "filename_foo"}], "/tmp") == "/tmp"
    end
  end

  test "workflow tries to generate the PDFs" do
    with_mock File, [ls:      fn(_dir)       -> {:ok, ["1.jpg", "2.jpg"]} end,
                     mkdir_p: fn(_dir)       -> nil end,
                     rename:  fn(_from, _to) -> nil end] do
      with_mock Porcelain, [shell: fn(_cmd) -> nil end] do
        Workflow.compile_pdfs("/tmp/manga_foo", "manga_foo")

        assert called File.rename("/tmp/manga_foo/1.jpg", "/tmp/manga_foo/manga_foo_1/1.jpg")
        assert called File.rename("/tmp/manga_foo/2.jpg", "/tmp/manga_foo/manga_foo_1/2.jpg")
        assert called Porcelain.shell("convert /tmp/manga_foo/manga_foo_1/*.jpg /tmp/manga_foo/manga_foo_1.pdf")
      end
    end
  end
end
