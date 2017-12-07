defmodule ExMangaDownloadr.MangafoxTest do
  use ExUnit.Case
  use ExMangaDownloadr, :mangafox

  @test_manga_url "http://mangafox.la/manga/21st_century_boys/"
  @manga_title "21ST CENTURY BOYS Manga"
  @expected_chapters ["//mangafox.la/manga/21st_century_boys/v02/c016/1.html", "//mangafox.la/manga/21st_century_boys/v02/c015/1.html", "//mangafox.la/manga/21st_century_boys/v02/c014/1.html", "//mangafox.la/manga/21st_century_boys/v02/c013/1.html", "//mangafox.la/manga/21st_century_boys/v02/c012/1.html", "//mangafox.la/manga/21st_century_boys/v02/c011/1.html", "//mangafox.la/manga/21st_century_boys/v02/c010/1.html", "//mangafox.la/manga/21st_century_boys/v02/c009/1.html", "//mangafox.la/manga/21st_century_boys/v01/c008/1.html", "//mangafox.la/manga/21st_century_boys/v01/c007/1.html", "//mangafox.la/manga/21st_century_boys/v01/c006/1.html", "//mangafox.la/manga/21st_century_boys/v01/c005/1.html", "//mangafox.la/manga/21st_century_boys/v01/c004/1.html", "//mangafox.la/manga/21st_century_boys/v01/c003/1.html", "//mangafox.la/manga/21st_century_boys/v01/c002/1.html", "//mangafox.la/manga/21st_century_boys/v01/c001/1.html"]

  @expected_pages ["//mangafox.la/manga/21st_century_boys/v02/c015/1.html", "//mangafox.la/manga/21st_century_boys/v02/c015/2.html", "//mangafox.la/manga/21st_century_boys/v02/c015/3.html", "//mangafox.la/manga/21st_century_boys/v02/c015/4.html", "//mangafox.la/manga/21st_century_boys/v02/c015/5.html", "//mangafox.la/manga/21st_century_boys/v02/c015/6.html", "//mangafox.la/manga/21st_century_boys/v02/c015/7.html", "//mangafox.la/manga/21st_century_boys/v02/c015/8.html", "//mangafox.la/manga/21st_century_boys/v02/c015/9.html", "//mangafox.la/manga/21st_century_boys/v02/c015/10.html", "//mangafox.la/manga/21st_century_boys/v02/c015/11.html", "//mangafox.la/manga/21st_century_boys/v02/c015/12.html", "//mangafox.la/manga/21st_century_boys/v02/c015/13.html", "//mangafox.la/manga/21st_century_boys/v02/c015/14.html", "//mangafox.la/manga/21st_century_boys/v02/c015/15.html", "//mangafox.la/manga/21st_century_boys/v02/c015/16.html", "//mangafox.la/manga/21st_century_boys/v02/c015/17.html", "//mangafox.la/manga/21st_century_boys/v02/c015/18.html", "//mangafox.la/manga/21st_century_boys/v02/c015/19.html", "//mangafox.la/manga/21st_century_boys/v02/c015/20.html", "//mangafox.la/manga/21st_century_boys/v02/c015/21.html", "//mangafox.la/manga/21st_century_boys/v02/c015/22.html", "//mangafox.la/manga/21st_century_boys/v02/c015/23.html", "//mangafox.la/manga/21st_century_boys/v02/c015/24.html", "//mangafox.la/manga/21st_century_boys/v02/c015/25.html"]

  @expected_image_src "https://lmfcdn.secure.footprint.net/store/manga/763/02-015.0/compressed/21stcenturyboys_c15_001.jpg"
  @expected_image_alt "00015-00001.jpg"

  test "get all chapters available for the manga" do
    {:ok, {manga_title, chapter_list}} = IndexPage.chapters(@test_manga_url)
    assert manga_title == @manga_title
    assert Enum.slice(chapter_list, 0, Enum.count(@expected_chapters)) == @expected_chapters
  end

  test "get all the pages of a given chapter" do
    {:ok, pages_list} = ChapterPage.pages(@expected_chapters |> Enum.at(1))
    assert pages_list == @expected_pages
  end

  test "get the main image of each page" do
    {:ok, {image_src, image_alt}} = Page.image(@expected_pages |> Enum.at(0))
    assert image_src |> String.split("?") |> Enum.at(0) == @expected_image_src
    assert image_alt == @expected_image_alt    
  end
end
