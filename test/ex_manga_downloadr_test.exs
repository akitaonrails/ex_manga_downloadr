defmodule ExMangaDownloadrTest do
  use ExUnit.Case, async: false
  alias ExMangaDownloadr.Workflow

  doctest ExMangaDownloadr

  defmodule Expected do
    def chapters, do: [
      "/boku-wa-ookami/1",
      "/boku-wa-ookami/2",
      "/boku-wa-ookami/3"
    ]

    def pages, do: [
      "/boku-wa-ookami/1",
      "/boku-wa-ookami/1/2",
      "/boku-wa-ookami/1/3"
    ]

    def image, do: {
      "http://i3.mangareader.net/boku-wa-ookami/1/boku-wa-ookami-2523599.jpg",
      "Ookami wa Boku 00001 - Page 00001.jpg"
    }
  end

  defmodule FakeMangaSource do
    @behaviour ExMangaDownloadr.MangaSource.Behaviour

    def applies?(_url), do: true
    def index_page("http://foo.com"), do: {:ok, {"Title", Expected.chapters()}}
    def chapter_page("page_link"), do: {:ok, Expected.pages()}
    def page_image("chapter_link"), do: {:ok, Expected.image()}
  end

  test "workflow fetches chapters" do
    chapters_list = {"http://foo.com", FakeMangaSource} |> Workflow.chapters()

    assert chapters_list == {Expected.chapters(), FakeMangaSource}
  end

  test "workflow fetches pages from chapters" do
    pages_list = {["page_link"], FakeMangaSource} |> Workflow.pages()

    assert pages_list == {Expected.pages(), FakeMangaSource}
  end

  test "workflow fetches image sources from pages" do
    images_list = {["chapter_link"], FakeMangaSource} |> Workflow.images_sources()

    assert images_list == [Expected.image()]
  end

  test "workflow tries to download the images" do
    {:ok, tmpdir} = Briefly.create(directory: true)

    assert Workflow.process_downloads([{"http://src_foo", "filename"}], tmpdir) == tmpdir
    assert File.read("#{tmpdir}/filename") == {:ok, "fake_response"}
  end

  test "workflow skips existing images" do
    {:ok, tmpdir} = Briefly.create(directory: true)

    File.touch! "#{tmpdir}/filename"

    assert Workflow.process_downloads([{"http://src_foo", "filename"}], tmpdir) == tmpdir
    assert File.read("#{tmpdir}/filename") == {:ok, ""}
  end

  test "workflow tries to generate the PDFs" do
    import Mock

    {:ok, tmpdir} = Briefly.create(directory: true)
    Enum.each [1, 2], &File.write("#{tmpdir}/#{&1}.jpg", "file#{&1}")

    with_mock Porcelain, [shell: fn(_cmd) -> nil end] do
      Workflow.compile_pdfs(tmpdir, "manga_foo")

      refute File.exists?("#{tmpdir}/1.jpg")
      refute File.exists?("#{tmpdir}/2.jpg")
      assert File.read("#{tmpdir}/manga_foo_1/1.jpg") == {:ok, "file1"}
      assert File.read("#{tmpdir}/manga_foo_1/2.jpg") == {:ok, "file2"}
      assert called Porcelain.shell("convert #{tmpdir}/manga_foo_1/*.jpg #{tmpdir}/manga_foo_1.pdf")
    end
  end
end
