defmodule ExMangaDownloadr.Support.Fixture do
  @fixtures_dir Path.join([File.cwd!, "test", "fixtures"])

  def read(path, base) do
    case path |> dir(base) |> File.read() do
      {:ok, body} -> body
      _ -> raise "Could not find fixture #{path}"
    end
  end

  defp dir(path, base) do
    Path.join([@fixtures_dir, base, path])
  end
end
