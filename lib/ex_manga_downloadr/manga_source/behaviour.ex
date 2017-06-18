defmodule ExMangaDownloadr.MangaSource.Behaviour do
  @type manga_title :: String.t
  @type url :: String.t
  @type chapter_url :: url
  @type page_url :: url
  @type image_url :: url
  @type image_name :: String.t
  @type chapter_list :: [url]
  @type page_list :: [url]

  @callback applies?(url) :: boolean
  @callback index_page(url) :: {manga_title, chapter_list}
  @callback chapter_page(chapter_url) :: {:ok, page_list}
  @callback page_image(url) :: {:ok, [{image_url, image_name}]}
end
