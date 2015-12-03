defmodule PoolManagement.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    pool_size = System.get_env("POOL_SIZE") || "50"
    pool_options = [
      name: {:local, :worker_pool},
      worker_module: PoolManagement.Worker,
      size: String.to_integer(pool_size),
      max_overflow: 0
    ]

    children = [
      :poolboy.child_spec(:worker_pool, pool_options, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end