# ExMangaDownloadr

This is an exercise in my path to learn Elixir. It is a simpler port of the Ruby tool ["Manga Downloadr"](https://github.com/akitaonrails/manga-downloadr) which can also be used to fetch a manga from MangaReader.net.

Right now this is not particularly exciting because parallel fetching is being forcefully capped. My limitation in how to properly deal with Async downloads made me parallel fetch one chapter at a time.

Not so sure if I need to use the HTTPotion Async support or create an Agent/GenServer from scratch with a proper Supervisor to retry connections. It seems that it I try to spawn one process for all the images at the same time (or even to fetch all the pages from all the chapters all at once), HTTPotion just blows up unexplicably. Not sure how to improve that so far.

## Installation

This can be compiled as a command line tool:

  1. Fetch dependencies:

        mix deps.get

  2. Run tests if you want to contribute:

        mix test

  3. Build

        mix escript.build 

  4. Try to fetch a small manga to test it working:

        ./ex_manga_downloadr -u http://www.mangareader.net/boku-wa-ookami -d /tmp/boku-wa-ookami 