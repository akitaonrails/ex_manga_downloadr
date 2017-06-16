defmodule ExMangaDownloadr.MangaSource.MangafoxTest do
  use ExUnit.Case
  alias ExMangaDownloadr.MangaSource.Mangafox
  import TestHelper, only: [extract_value: 1]

  @url "http://mangafox.me/manga/death_note/index.html"
  @manga_title "DEATH NOTE Manga"
  @expected_chapters [
    "http://mangafox.me/manga/death_note/vTBD/c110.5/1.html",
    "http://mangafox.me/manga/death_note/vTBD/c110/1.html",
    "http://mangafox.me/manga/death_note/v12/c108/1.html",
    "http://mangafox.me/manga/death_note/v12/c107/1.html"
  ]
  @expected_pages [
    ["http://mangafox.me/manga/death_note/vTBD/c110.5/1.html"],
    ["http://mangafox.me/manga/death_note/vTBD/c110/1.html"],
    ["http://mangafox.me/manga/death_note/v12/c108/1.html"],
    [
      "http://mangafox.me/manga/death_note/v12/c107/1.html",
      "http://mangafox.me/manga/death_note/v12/c107/2.html"
    ]
  ]
  @expected_images_list [
    [{"http://h.mfcdn.net/TBD-110.5/01.jpg?token=token", "110.5-00001.jpg"}],
    [{"http://h.mfcdn.net/TBD-110.000.jpg?token=token", "00110-00001.jpg"}],
    [{"http://h.mfcdn.net/12-108.0/DN_01.jpg?token=token", "00108-00001.jpg"}],
    [
      {"http://h.mfcdn.net/12-107.0/DN_01.jpg?token=token", "00107-00001.jpg"},
      {"http://h.mfcdn.net/12-107.0/DN_02.jpg?token=token", "00107-00002.jpg"}
    ]
  ]

  test "get all chapters available for the manga" do
    {manga_title, chapter_list} = Mangafox.index_page(@url) |> extract_value

    assert manga_title == @manga_title
    assert chapter_list == @expected_chapters
  end

  test "get all the pages of a given chapter" do
    pages_list = Enum.map @expected_chapters, fn chapter_url ->
      Mangafox.chapter_page(chapter_url) |> extract_value
    end

    assert pages_list == @expected_pages
  end

  test "get the main image of each page" do
    images_list = Enum.map @expected_pages, fn list ->
      Enum.map list, &Mangafox.page_image(&1) |> extract_value
    end

    assert images_list == @expected_images_list
  end
end
