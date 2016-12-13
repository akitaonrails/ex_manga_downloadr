defmodule ExMangaDownloadr.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_manga_downloadr,
     version: "1.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: ExMangaDownloadr.CLI],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison, :porcelain, :observer],
     mod: {PoolManagement, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.10"},
      {:floki, "~> 0.9.0"},
      {:porcelain, "~> 2.0.1"},
      {:poolboy, "~> 1.5.1"},
      {:mock, "~> 0.1.3", only: :test}
    ]
  end
end
