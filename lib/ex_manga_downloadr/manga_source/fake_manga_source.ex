defmodule ExMangaDownloadr.MangaSource.FakeMangaSource do
  defmodule Fake do
    @behaviour ExMangaDownloadr.MangaSource

    def expected_manga_title do
      "Boku wa Ookami Manga"
    end

    def expected_chapters do
      ["/boku-wa-ookami/1", "/boku-wa-ookami/2", "/boku-wa-ookami/3"]
    end

    def expected_pages do
      ["/boku-wa-ookami/1", "/boku-wa-ookami/1/2", "/boku-wa-ookami/1/3"]
    end

    def expected_image do
      {
        "http://i3.mangareader.net/boku-wa-ookami/1/boku-wa-ookami-2523599.jpg",
        "Ookami wa Boku 00001 - Page 00001.jpg"
      }
    end

    def applies?(_url), do: true

    def index_page(_url) do
      {:ok, {expected_manga_title(), expected_chapters()}}
    end

    def chapter_page(_page_link) do
      {:ok, expected_pages()}
    end

    def page_image(_page_link) do
      {:ok, expected_image()}
    end
  end

  def find("http://foo.com/bar") do
    {:ok, Fake}
  end
end
