defmodule ExMangaDownloadr.Cache.FS do
  @behaviour ExMangaDownloadr.Cache.Behaviour

  def call(id, options, callback) do
    id
    |> read(options)
    |> do_call(id, options, callback)
  end

  def read(id, options) do
    case cache_path(id, options) |> File.read do
      {:ok, contents} -> contents
      _ -> :cache_miss
    end
  end

  def write(id, contents, options) do
    id
    |> cache_path(options)
    |> File.write!(contents)
  end

  defp cache_path(id, options) do
    Path.join(options[:dir], filename(id))
  end

  defp filename(id) do
    :md5
    |> :crypto.hash(id)
    |> Base.encode16()
  end

  defp do_call(:cache_miss, id, options, callback) do
    value = callback.(:cache_miss, "")
    extract = options[:extractor] || &(&1)

    write id, extract.(value), options

    value
  end

  defp do_call(contents, _, _, callback) do
    callback.(:cache_hit, contents)
  end
end
