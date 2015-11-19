defmodule PoolManagement do
  use Application

  def start(_type, _args) do
    PoolManagement.Supervisor.start_link
  end
end