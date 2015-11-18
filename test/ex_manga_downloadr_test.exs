defmodule ExMangaDownloadrTest do
  use ExUnit.Case, async: false
  use ExMangaDownloadr.MangaReader
  alias ExMangaDownloadr.Workflow
  doctest ExMangaDownloadr

  import Mock

  @expected_manga_title "Boku wa Ookami Manga"
  @expected_chapters {:ok, @expected_manga_title,
    ["/boku-wa-ookami/1", "/boku-wa-ookami/2", "/boku-wa-ookami/3"]}
  @expected_pages {:ok,
    ["/boku-wa-ookami/1", "/boku-wa-ookami/1/2", "/boku-wa-ookami/1/3"]}
  @expected_image {:ok,
    {"http://i3.mangareader.net/boku-wa-ookami/1/boku-wa-ookami-2523599.jpg",
      "Ookami wa Boku 00001 - Page 00001.jpg"}}

  test "workflow fetches chapters" do
    with_mock IndexPage, [chapters: fn(_url) -> @expected_chapters end] do
      assert {:ok, @expected_manga_title, Workflow.chapters("foo")} == @expected_chapters
    end
  end

  test "workflow fetches pages from chapters" do
    with_mock ChapterPage, [pages: fn(_chapter_link) -> @expected_pages end] do
      assert {:ok, Workflow.pages(["foo"])} == @expected_pages
    end
  end

  test "workflow fetches image sources from pages" do
    with_mock Page, [image: fn(_page_link) -> @expected_image end] do
      {:ok, image} = @expected_image
      assert Workflow.images_sources(["foo"]) == [image]
    end
  end

  test "workflow tries to download the images" do
    with_mock HTTPotion, [get: fn(_url, _options) -> %HTTPotion.Response{ body: nil, headers: nil, status_code: 200 } end] do
      with_mock File, [write!: fn(_filename, _body) -> nil end] do
        assert Workflow.process_downloads([{"http://src_foo", "filename_foo"}], "/tmp") == [{:ok, "http://src_foo", "/tmp/filename_foo"}]

        assert called HTTPotion.get("http://src_foo", [timeout: 30_000])
        assert called File.write!("/tmp/filename_foo", nil)
      end
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
