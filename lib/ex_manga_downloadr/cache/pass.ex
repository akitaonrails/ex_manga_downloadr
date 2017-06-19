defmodule ExMangaDownloadr.Cache.Pass do
  @behaviour ExMangaDownloadr.Cache.Behaviour

  def call(_, _, cb), do: cb.(:cache_miss, "")
end
