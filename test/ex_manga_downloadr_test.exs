defmodule ExMangaDownloadrTest do
  use ExUnit.Case, async: false
  alias ExMangaDownloadr.Workflow

  doctest ExMangaDownloadr

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
    {:ok, tmpdir} = Briefly.create(directory: true)

    assert Workflow.process_downloads([{"http://src_foo", "filename_foo"}], tmpdir) == tmpdir
    assert File.read("#{tmpdir}/filename_foo") == {:ok, "fake_response"}
  end

  test "workflow skips existing images" do
    {:ok, tmpdir} = Briefly.create(directory: true)

    File.touch! "#{tmpdir}/filename_foo"

    assert Workflow.process_downloads([{"http://src_foo", "filename_foo"}], tmpdir) == tmpdir
    assert File.read("#{tmpdir}/filename_foo") == {:ok, ""}
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
