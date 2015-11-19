defmodule PoolManagement.Worker do
  use GenServer
  use ExMangaDownloadr.MangaReader

  @timeout_ms 1_000_000
  @transaction_timeout_ms 1_000_000 # larget just to be safe

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  # Public APIs

  def page_image(page_link) do
    Task.async fn -> 
      :poolboy.transaction :worker_pool, fn(server) ->
        GenServer.call(server, {:page_image, page_link}, @timeout_ms)
      end, @transaction_timeout_ms
    end
  end

  def page_download_image(image_data, directory) do
    Task.async fn -> 
      :poolboy.transaction :worker_pool, fn(server) ->
        GenServer.call(server, {:page_download_image, image_data, directory}, @timeout_ms)
      end, @transaction_timeout_ms
    end
  end

  # internal GenServer implementation

  def handle_call({:page_image, page_link}, _from, state) do
    {:reply, Page.image(page_link), state}
  end

  def handle_call({:page_download_image, image_data, directory}, _from, state) do
    {:reply, Page.download_image(image_data, directory), state}
  end
end