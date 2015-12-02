defmodule ExMangaDownloadr.Mangafox.Page do
  require Logger

  @user_agent Application.get_env(:ex_manga_downloadr, :user_agent)

  def image(page_link) do
    Logger.debug("Fetching image source from page #{page_link}")
    case HTTPotion.get(page_link, [
      headers: ["User-Agent": @user_agent, "Accept-encoding": "gzip"], timeout: 30_000]) do
      %HTTPotion.Response{ body: body, headers: headers, status_code: 200 } ->
        { :ok, fetch_image(page_link, ExMangaDownloadr.Mangafox.gunzip(body, headers)) }
      _ ->
        { :err, "not found"}
    end
  end

  defp fetch_image(page_link, html) do
    html
    |> Floki.find("div[class='read_img'] img")
    |> Enum.map(fn line ->
         case line do
           {"img", [{"src", image_src}, {"onerror", _}, {"width", _},
                    {"id", "image"}, {"alt", _}], _} ->
             extension = image_src |> String.split(".") |> Enum.reverse |> Enum.at(0)
             tokens    = page_link |> String.split("/") |> Enum.reverse
             filename = Enum.at(tokens, 0) |> String.split(".") |> Enum.at(0) |> String.rjust(5, ?0)
             {image_src, "#{Enum.at(tokens, 2)}-#{Enum.at(tokens, 1)}-#{filename}.#{extension}"}
         end
       end)
    |> Enum.at(0)
  end
end