defmodule ExMangaDownloadr.Mangafox.Page do
  require Logger

  @user_agent Application.get_env(:ex_manga_downloadr, :user_agent)

  def image(page_link) do
    Logger.debug("Fetching image source from page #{page_link}")
    case HTTPotion.get(page_link, [
      headers: ["User-Agent": @user_agent, "Accept-encoding": "gzip"], timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: headers, status_code: 200 } ->
        { :ok, fetch_image(ExMangaDownloadr.Mangafox.gunzip(body, headers)) }
      _ ->
        { :err, "not found"}
    end
  end

  defp fetch_image(html) do
    html
    |> Floki.find("div[class='read_img'] img")
    |> Enum.map(fn line ->
         case line do
           {"img", [{"src", image_src}, {"onerror", _}, {"width", _},
                    {"id", "image"}, {"alt", image_alt}], _} ->
             [file|_tokens] = image_src |> String.split("/") |> Enum.reverse
             {image_src, "#{image_alt}-#{file}"}
         end
       end)
    |> Enum.at(0)
  end
end