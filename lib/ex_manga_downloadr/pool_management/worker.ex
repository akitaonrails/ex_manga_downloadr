defmodule PoolManagement.Worker do
  use GenServer
  require Logger

  @genserver_call_timeout 1_000_000
  @task_async_timeout     1_000_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  # Public APIs

  def index_page(url, source) do
    # this is not a wrapper to a handle_call but adding in the Worker because it is more relatable
    source 
      |> manga_source("IndexPage")
      |> apply(:chapters, [url])
  end

  def chapter_page([chapter_link, source]) do
    Task.async fn -> 
      :poolboy.transaction :worker_pool, fn(server) ->
        GenServer.call(server, {:chapter_page, chapter_link, source}, @genserver_call_timeout)
      end, @task_async_timeout
    end
  end

  def page_image([page_link, source]) do
    Task.async fn -> 
      :poolboy.transaction :worker_pool, fn(server) ->
        GenServer.call(server, {:page_image, page_link, source}, @genserver_call_timeout)
      end, @task_async_timeout
    end
  end

  def page_download_image(image_data, directory) do
    Task.async fn -> 
      :poolboy.transaction :worker_pool, fn(server) ->
        GenServer.call(server, {:page_download_image, image_data, directory}, @genserver_call_timeout)
      end, @task_async_timeout
    end
  end

  # internal GenServer implementation

  def handle_call({:chapter_page, chapter_link, source}, _from, state) do
    links = source
      |> manga_source("ChapterPage")
      |> apply(:pages, [chapter_link])
    {:reply, links, state}
  end

  def handle_call({:page_image, page_link, source}, _from, state) do
    images = source
      |> manga_source("Page")
      |> apply(:image, [page_link])
    {:reply, images, state}
  end

  def handle_call({:page_download_image, image_data, directory}, _from, state) do
    {:reply, download_image(image_data, directory), state}
  end

  ## Helper functions

  defp manga_source(source, module) do
    case source do
      "mangareader" -> :"Elixir.ExMangaDownloadr.MangaReader.#{module}"
      "mangafox"    -> :"Elixir.ExMangaDownloadr.Mangafox.#{module}"
    end
  end

  defp download_image({image_src, image_filename}, directory) do
    filename = "#{directory}/#{image_filename}"
    if File.exists?(filename) do
      Logger.debug("Image #{filename} already downloaded, skipping.")
      {:ok, image_src, filename}
    else
      Logger.debug("Downloading image #{image_src} to #{filename}")
      case HTTPotion.get(image_src, ExMangaDownloadr.http_headers) do
        %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
          File.write!(filename, body)
          {:ok, image_src, filename}
        _ ->
          {:err, image_src}
      end
    end
  end
end