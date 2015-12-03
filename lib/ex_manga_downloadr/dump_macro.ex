defmodule ExMangaDownloadr.DumpMacro do
  defmacro manage(directory, expression) do
    quote do
      dump_file = "#{unquote(directory)}/images_list.dump"
      images_list = if File.exists?(dump_file) do
          :erlang.binary_to_term(File.read!(dump_file))
        else
          list = unquote(expression)
          File.write(dump_file, :erlang.term_to_binary(list))
          list
        end
    end
  end
end