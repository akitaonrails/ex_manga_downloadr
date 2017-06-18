defmodule ExMangaDownloadr do
  def apply_env_options(list) do
    if System.get_env("END_TO_END_TEST_MODE") do
      list |> Enum.slice(0, 2)
    else
      list
    end
  end

  def create_cache_dir, do: File.mkdir_p! cache_dir()
  def cache_dir, do: "/tmp/ex_manga_downloadr_cache"
  def cache_handler do
    if System.get_env("CACHE_HTTP") do
      :fs
    else
      :pass
    end
  end
end
