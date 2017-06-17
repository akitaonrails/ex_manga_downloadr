defmodule MangaSourceTest do
  use ExUnit.Case, async: true
  alias ExMangaDownloadr.MangaSource
  alias MangaSource.{MangaReader, Mangafox}

  test "delivers a MangaReader source struct when URL matches" do
    url = "http://www.mangareader.net/boku-wa-ookami"

    assert MangaSource.find(url) == {:ok, MangaReader}
  end

  test "delivers a Mangafox source struct when URL matches" do
    url = "http://mangafox.me/manga/onepunch_man"

    assert MangaSource.find(url) == {:ok, Mangafox}
  end

  test "delivers :error when URL does not match" do
    url = "http://www.google.com/search?q=test"

    assert MangaSource.find(url) == :error
  end
end
