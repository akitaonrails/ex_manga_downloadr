Application.ensure_all_started :briefly

ExUnit.start()

defmodule TestHelper do
  def extract_value({:ok, value}), do: value
end
