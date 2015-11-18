defmodule ExMangaDownloadrTest do
  use ExUnit.Case
  alias ExMangaDownloadr.IndexPage
  alias ExMangaDownloadr.ChapterPage
  alias ExMangaDownloadr.Page
  alias ExMangaDownloadr.Workflow
  doctest ExMangaDownloadr

  @test_manga_url "http://www.mangareader.net/onepunch-man"
  @manga_title "Onepunch-Man Manga"
  @expected_chapters ["/onepunch-man/1", "/onepunch-man/2", "/onepunch-man/3", "/onepunch-man/4",
    "/onepunch-man/5", "/onepunch-man/6", "/onepunch-man/7", "/onepunch-man/8", "/onepunch-man/9",
    "/onepunch-man/10", "/onepunch-man/11", "/onepunch-man/12", "/onepunch-man/13", "/onepunch-man/14",
    "/onepunch-man/15", "/onepunch-man/16", "/onepunch-man/17", "/onepunch-man/18", "/onepunch-man/19",
    "/onepunch-man/20", "/onepunch-man/21", "/onepunch-man/22", "/onepunch-man/23", "/onepunch-man/24",
    "/onepunch-man/25", "/onepunch-man/26", "/onepunch-man/27", "/onepunch-man/28", "/onepunch-man/29",
    "/onepunch-man/30", "/onepunch-man/31", "/onepunch-man/32", "/onepunch-man/33", "/onepunch-man/34",
    "/onepunch-man/35", "/onepunch-man/36", "/onepunch-man/37", "/onepunch-man/38", "/onepunch-man/39",
    "/onepunch-man/40", "/onepunch-man/41", "/onepunch-man/42", "/onepunch-man/43", "/onepunch-man/44",
    "/onepunch-man/45", "/onepunch-man/46", "/onepunch-man/47", "/onepunch-man/48", "/onepunch-man/49",
    "/onepunch-man/50", "/onepunch-man/51", "/onepunch-man/52", "/onepunch-man/53", "/onepunch-man/54",
    "/onepunch-man/55", "/onepunch-man/56", "/onepunch-man/57", "/onepunch-man/58", "/onepunch-man/59",
    "/onepunch-man/60", "/onepunch-man/61", "/onepunch-man/62", "/onepunch-man/63", "/onepunch-man/64",
    "/onepunch-man/65", "/onepunch-man/66", "/onepunch-man/67", "/onepunch-man/68", "/onepunch-man/69",
    "/onepunch-man/70", "/onepunch-man/71", "/onepunch-man/72", "/onepunch-man/73", "/onepunch-man/74",
    "/onepunch-man/75", "/onepunch-man/76", "/onepunch-man/77", "/onepunch-man/78", "/onepunch-man/79",
    "/onepunch-man/80", "/onepunch-man/81", "/onepunch-man/82", "/onepunch-man/83"]

  @expected_pages ["/onepunch-man/1", "/onepunch-man/1/2", "/onepunch-man/1/3",
    "/onepunch-man/1/4", "/onepunch-man/1/5", "/onepunch-man/1/6",
    "/onepunch-man/1/7", "/onepunch-man/1/8", "/onepunch-man/1/9",
    "/onepunch-man/1/10", "/onepunch-man/1/11", "/onepunch-man/1/12",
    "/onepunch-man/1/13", "/onepunch-man/1/14", "/onepunch-man/1/15",
    "/onepunch-man/1/16", "/onepunch-man/1/17", "/onepunch-man/1/18",
    "/onepunch-man/1/19"]

  @expected_image_src "http://i3.mangareader.net/onepunch-man/1/onepunch-man-3798615.jpg"
  @expected_image_alt "Onepunch-Man 00001 - Page 00001.jpg"

  test "get all chapters available for the manga" do
    {:ok, manga_title, chapter_list} = IndexPage.chapters(@test_manga_url)
    assert manga_title == @manga_title
    assert chapter_list == @expected_chapters
  end

  test "get all the pages of a given chapter" do
    {:ok, pages_list} = ChapterPage.pages(@expected_chapters |> Enum.at(0))
    assert pages_list == @expected_pages
  end

  test "get the main image of each page" do
    {:ok, {image_src, image_alt}} = Page.image(@expected_pages |> Enum.at(0))
    assert image_src == @expected_image_src
    assert image_alt == @expected_image_alt    
  end
end
