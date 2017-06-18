Application.ensure_all_started :briefly

ExUnit.configure exclude: [:slow]
ExUnit.start()

ExMangaDownloadr.create_cache_dir

defmodule TestHelper do
  def extract_value({:ok, value}), do: value
end
