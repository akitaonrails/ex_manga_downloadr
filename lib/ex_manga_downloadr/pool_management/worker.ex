defmodule PoolManagement.Worker do
  use GenServer
  require Logger

  @user_agent Application.get_env(:ex_manga_downloadr, :user_agent)
  @http_timeout 60_000

  @timeout_ms 1_000_000
  @transaction_timeout_ms 1_000_000 # larger just to be safe

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  # Public APIs
  def manga_source(source, module) do
    case source do
      "mangareader" -> :"Elixir.ExMangaDownloadr.MangaReader.#{module}"
      "mangafox"    -> :"Elixir.ExMangaDownloadr.Mangafox.#{module}"
    end
  end

  def chapter_page([chapter_link, source]) do
    Task.async fn -> 
      :poolboy.transaction :worker_pool, fn(server) ->
        GenServer.call(server, {:chapter_page, chapter_link, source}, @timeout_ms)
      end, @transaction_timeout_ms
    end
  end

  def page_image([page_link, source]) do
    Task.async fn -> 
      :poolboy.transaction :worker_pool, fn(server) ->
        GenServer.call(server, {:page_image, page_link, source}, @timeout_ms)
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

  defp download_image({image_src, image_filename}, directory) do
    filename = "#{directory}/#{image_filename}"
    if File.exists?(filename) do
      Logger.debug("Image #{filename} already downloaded, skipping.")
      {:ok, image_src, filename}
    else
      Logger.debug("Downloading image #{image_src} to #{filename}")
      case HTTPotion.get(image_src,
        [headers: ["User-Agent": @user_agent], timeout: @http_timeout]) do
        %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
          File.write!(filename, body)
          {:ok, image_src, filename}
        _ ->
          {:err, image_src}
      end
    end
  end
end