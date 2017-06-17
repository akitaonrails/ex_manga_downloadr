defmodule ExMangaDownloadr.MangaSource.Behaviour do
  @callback applies?(source :: String.t) :: boolean()
  @callback index_page(url :: String.t) :: {String.t, [...]}
  @callback chapter_page(page_link :: String.t) :: {:ok, any}
  @callback page_image(page_link :: String.t) :: {:ok, any}
end
