defmodule ExMangaDownloadr.MangaSource.MangaReaderTest do
  use ExUnit.Case
  alias ExMangaDownloadr.MangaSource.MangaReader
  import TestHelper, only: [extract_value: 1]

  @url "http://www.mangareader.net/death-note/index.html"
  @manga_title "Death Note Manga"
  @expected_chapters ["/death-note/1/index.html", "/death-note/2/index.html"]
  @expected_pages [
    "/death-note/1/index.html",
    "/death-note/1/2/index.html",
    "/death-note/1/3/index.html",
    "/death-note/2/index.html",
    "/death-note/2/2/index.html"
  ]
  @expected_images_list [
    {"http://i2.mangareader.net/death-note/1/death-note-1563523.jpg", "Note Death 00001 - Page 00001.jpg"},
    {"http://i8.mangareader.net/death-note/1/death-note-1563524.jpg", "Note Death 00001 - Page 00002.jpg"},
    {"http://i4.mangareader.net/death-note/1/death-note-1563525.jpg", "Note Death 00001 - Page 00003.jpg"},
    {"http://i2.mangareader.net/death-note/2/death-note-89336.jpg", "Note Death 00002 - Page 00001.jpg"},
    {"http://i4.mangareader.net/death-note/2/death-note-89337.jpg", "Note Death 00002 - Page 00002.jpg"}
  ]

  test "get all chapters available for the manga" do
    {manga_title, chapter_list} = @url |> MangaReader.index_page |> extract_value

    assert manga_title == @manga_title
    assert chapter_list == @expected_chapters
  end

  test "get all the pages of a given chapter" do
    pages_list = @expected_chapters |> Enum.flat_map(fn chapter_url ->
      chapter_url |> MangaReader.chapter_page |> extract_value
    end)

    assert pages_list == @expected_pages
  end

  test "get the main image of each page" do
    images_list = @expected_pages |> Enum.map(fn page_url ->
      page_url |> MangaReader.page_image |> extract_value
    end)

    assert images_list == @expected_images_list
  end
end
