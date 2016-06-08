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

## Usage

Try to fetch a small manga to test it working:

    ./ex_manga_downloadr -u http://www.mangareader.net/boku-wa-ookami -d /tmp/boku-wa-ookami

Mangafox CDN seems to restrict the amount of concurrent requests from the same origin, so if you're seeing too many crashes due to requests being denied, you can try to downgrade the maximum number of concurrent connections like this:

    POOL_SIZE=10 ./ex_manga_downloadr -u http://mangafox.me/manga/onepunch_man/ -d /tmp/onepunch

So, prefer to use Mangareader if possible. Or you can combine with HTTP cache so you can resume if the operation is interrupted:

    CACHE_SIZE=true ./ex_manga_downloadr -u http://mangafox.me/manga/onepunch_man/ -d /tmp/onepunch

## Test Mode

You can turn on test mode to compare this implementation against my other manga downloaders, just do this:

    time ./ex_manga_downloadr --test

And you can combine with caching to test just the processing parts:

    time CACHE_HTTP=true ./ex_manga_downloadr --test

This mode will use One-Punch Man as the sample manga and it will skip the actual download, optimization and pdf compilation.
