defmodule ExMangaDownloadr.MangaReaderTest do
  use ExUnit.Case
  alias ExMangaDownloadr.MangaReader

  @test_manga_url "http://www.mangareader.net/death-note"
  @manga_title "Death Note Manga"
  @expected_chapters ["/death-note/1", "/death-note/2", "/death-note/3", "/death-note/4", "/death-note/5", "/death-note/6", "/death-note/7", "/death-note/8", "/death-note/9", "/death-note/10", "/death-note/11", "/death-note/12", "/death-note/13", "/death-note/14", "/death-note/15", "/death-note/16", "/death-note/17", "/death-note/18", "/death-note/19", "/death-note/20", "/death-note/21", "/death-note/22", "/death-note/23", "/death-note/24", "/death-note/25", "/death-note/26", "/death-note/27", "/death-note/28", "/death-note/29", "/death-note/30", "/death-note/31", "/death-note/32", "/death-note/33", "/death-note/34", "/death-note/35", "/death-note/36", "/death-note/37", "/death-note/38", "/death-note/39", "/death-note/40", "/death-note/41", "/death-note/42", "/death-note/43", "/death-note/44", "/death-note/45", "/death-note/46", "/death-note/47", "/death-note/48", "/death-note/49", "/death-note/50", "/death-note/51", "/death-note/52", "/death-note/53", "/death-note/54", "/death-note/55", "/death-note/56", "/death-note/57", "/death-note/58", "/death-note/59", "/death-note/60", "/death-note/61", "/death-note/62", "/death-note/63", "/death-note/64", "/death-note/65", "/death-note/66", "/death-note/67", "/death-note/68", "/death-note/69", "/death-note/70", "/death-note/71", "/death-note/72", "/death-note/73", "/death-note/74", "/death-note/75", "/death-note/76", "/death-note/77", "/death-note/78", "/death-note/79", "/death-note/80", "/death-note/81", "/death-note/82", "/death-note/83", "/death-note/84", "/death-note/85", "/death-note/86", "/death-note/87", "/death-note/88", "/death-note/89", "/death-note/90", "/death-note/91", "/death-note/92", "/death-note/93", "/death-note/94", "/death-note/95", "/death-note/96", "/death-note/97", "/death-note/98", "/death-note/99", "/death-note/100", "/death-note/101", "/death-note/102", "/death-note/103", "/death-note/104", "/death-note/105", "/death-note/106", "/death-note/107", "/death-note/108", "/death-note/109"]
  @expected_pages ["/death-note/1", "/death-note/1/2", "/death-note/1/3", "/death-note/1/4", "/death-note/1/5", "/death-note/1/6", "/death-note/1/7", "/death-note/1/8", "/death-note/1/9", "/death-note/1/10", "/death-note/1/11", "/death-note/1/12", "/death-note/1/13", "/death-note/1/14", "/death-note/1/15", "/death-note/1/16", "/death-note/1/17", "/death-note/1/18", "/death-note/1/19", "/death-note/1/20", "/death-note/1/21", "/death-note/1/22", "/death-note/1/23", "/death-note/1/24", "/death-note/1/25", "/death-note/1/26", "/death-note/1/27", "/death-note/1/28", "/death-note/1/29", "/death-note/1/30", "/death-note/1/31", "/death-note/1/32", "/death-note/1/33", "/death-note/1/34", "/death-note/1/35", "/death-note/1/36", "/death-note/1/37", "/death-note/1/38", "/death-note/1/39", "/death-note/1/40", "/death-note/1/41", "/death-note/1/42", "/death-note/1/43", "/death-note/1/44", "/death-note/1/45", "/death-note/1/46", "/death-note/1/47", "/death-note/1/48", "/death-note/1/49", "/death-note/1/50"]

  @expected_image_src "http://i2.mangareader.net/death-note/1/death-note-1563523.jpg"
  @expected_image_alt "Note Death 00001 - Page 00001.jpg"

  test "get all chapters available for the manga" do
    {:ok, {manga_title, chapter_list}} = MangaReader.index_page(@test_manga_url)

    assert manga_title == @manga_title
    assert Enum.slice(chapter_list, 0, Enum.count(@expected_chapters)) == @expected_chapters
  end

  test "get all the pages of a given chapter" do
    {:ok, pages_list} = MangaReader.chapter_page(@expected_chapters |> Enum.at(0))

    assert pages_list == @expected_pages
  end

  test "get the main image of each page" do
    {:ok, {image_src, image_alt}} = MangaReader.page_image(@expected_pages |> Enum.at(0))

    assert image_src == @expected_image_src
    assert image_alt == @expected_image_alt
  end
end
