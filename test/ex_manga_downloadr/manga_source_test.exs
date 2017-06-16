defmodule MangaSourceTest do
  use ExUnit.Case, async: true
  alias ExMangaDownloadr.MangaSource
  alias ExMangaDownloadr.MangaSource.{MangaReader, Mangafox}

  test "delivers a MangaReader source struct when URL matches" do
    url = "http://www.mangareader.net/boku-wa-ookami"

    assert MangaSource.for(url) == {:ok, %MangaSource{url: url, module: MangaReader}}
  end

  test "delivers a Mangafox source struct when URL matches" do
    url = "http://mangafox.me/manga/onepunch_man"

    assert MangaSource.for(url) == {:ok, %MangaSource{url: url, module: Mangafox}}
  end

  test "delivers :error when URL does not match" do
    url = "http://www.google.com/search?q=test"

    assert MangaSource.for(url) == :error
  end
end
