defmodule ExMangaDownloadr.Cache do
  def call(handler_id, url, options, cb) do
    handler_for(handler_id).call(url, options, cb)
  end

  def handler_for(handler_id) do
    case handler_id do
      :fs -> ExMangaDownloadr.Cache.FS
      :pass -> ExMangaDownloadr.Cache.Pass
    end
  end
end
