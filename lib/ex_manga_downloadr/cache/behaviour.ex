defmodule ExMangaDownloadr.Cache.Behaviour do
  @type event_type :: :cache_hit | :cache_miss
  @type contents :: String.t
  @type options :: [dir: String.t, extractor: (any() -> contents)]

  @callback call(String.t, options, (event_type, contents -> any())) :: any()
end
