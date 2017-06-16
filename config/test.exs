use Mix.Config

config :ex_manga_downloadr, :manga_source, ExMangaDownloadr.MangaSource.FakeMangaSource
config :ex_manga_downloadr, :downloader, ExMangaDownloadr.Downloader.Mock
