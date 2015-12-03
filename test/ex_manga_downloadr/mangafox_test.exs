defmodule ExMangaDownloadr.MangafoxTest do
  use ExUnit.Case
  use ExMangaDownloadr, :mangafox

  @test_manga_url "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/"
  @manga_title "NOZO X KIMI - 2-NENSEI HEN Manga"
  @expected_chapters [
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c002/1.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/1.html"]

  @expected_pages ["http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/1.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/2.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/3.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/4.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/5.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/6.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/7.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/8.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/9.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/10.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/11.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/12.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/13.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/14.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/15.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/16.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/17.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/18.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/19.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/20.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/21.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/22.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/23.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/24.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/25.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/26.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/27.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/28.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/29.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/30.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/31.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/32.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/33.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/34.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/35.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/36.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/37.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/38.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/39.html",
    "http://mangafox.me/manga/nozo_x_kimi_2_nensei_hen/c001/40.html"]

  @expected_image_src "http://z.mfcdn.net/store/manga/14327/001.0/compressed/pnozomi_kimio_020_000.jpg"
  @expected_image_alt "nozo_x_kimi_2_nensei_hen-c001-00001.jpg"

  test "get all chapters available for the manga" do
    {:ok, {manga_title, chapter_list}} = IndexPage.chapters(@test_manga_url)
    assert manga_title == @manga_title
    assert chapter_list == @expected_chapters
  end

  test "get all the pages of a given chapter" do
    {:ok, pages_list} = ChapterPage.pages(@expected_chapters |> Enum.at(1))
    assert pages_list == @expected_pages
  end

  test "get the main image of each page" do
    {:ok, {image_src, image_alt}} = Page.image(@expected_pages |> Enum.at(0))
    assert image_src == @expected_image_src
    assert image_alt == @expected_image_alt    
  end
end
