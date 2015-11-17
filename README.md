# ExMangaDownloadr

This is an exercise in my path to learn Elixir. It is a simpler port of the Ruby tool ["Manga Downloadr"](https://github.com/akitaonrails/manga-downloadr) which can also be used to fetch a manga from MangaReader.net.

Right now this is not particularly exciting because parallel fetching is being forcefully capped. My limitation in how to properly deal with Async downloads made me parallel fetch one chapter at a time.

Not so sure if I need to use the HTTPotion Async support or create an Agent/GenServer from scratch with a proper Supervisor to retry connections. It seems that it I try to spawn one process for all the images at the same time (or even to fetch all the pages from all the chapters all at once), HTTPotion just blows up unexplicably. Not sure how to improve that so far.

The CLI.ex file is in sore need of a big refactoring to make the workflow more manageable. (I know, sorry)

One additional feature would be to save the current state of the workflow and resume if it ever raises an unexpected exception and halts before finishing.

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

        ./ex_manga_downloadr -name boku-wa-ookami -u http://www.mangareader.net/boku-wa-ookami -d /tmp/boku-wa-ookami