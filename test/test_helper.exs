ExUnit.start()

defmodule TestHelper do
  def extract_value({:ok, value}), do: value
end
