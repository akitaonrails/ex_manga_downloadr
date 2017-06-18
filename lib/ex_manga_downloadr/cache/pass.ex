defmodule ExMangaDownloadr.Cache.Pass do
  @behaviour ExMangaDownloadr.Cache.Behaviour

  def call(_, _, callback), do: callback.(:cache_miss, "")
end
