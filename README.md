# ExMangaDownloadr

This is an exercise in my path to learn Elixir. It is a simpler port of the Ruby tool ["Manga Downloadr"](https://github.com/akitaonrails/manga-downloadr) which can also be used to fetch a manga from MangaReader.net.

*Update:* this tool now also supports MangaFox! So check it out!

## Installation

This can be compiled as a command line tool:

  1. You will need to install ImageMagick in your system (to resize images to Kindle format and merge them into PDF volumes). Refer to your system's particular install. In Ubuntu, simply do:

        sudo apt-get install imagemagick

  2. Fetch Elixir dependencies:

        mix deps.get

  3. Run tests if you want to contribute:

        mix test

  4. Build

        mix escript.build

  5. Try to fetch a small manga to test it working:

        ./ex_manga_downloadr -n boku-wa-ookami -u http://www.mangareader.net/boku-wa-ookami -d /tmp/boku-wa-ookami -s mangareader

You can choose between "mangareader" and "mangafox" as sources