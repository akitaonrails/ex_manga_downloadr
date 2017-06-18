defmodule EndToEndTest do
  @moduletag [:slow]

  use ExUnit.Case

  def create_tmpdir(dir) do
    {:ok, tmpdir} = Briefly.create(directory: true)

    tmpdir |> Path.join(dir)
  end

  def run_manga_downloadr(options, env \\ "") do
    import Porcelain, only: [shell: 1]

    shell "mix escript.build"
    shell "END_TO_END_TEST_MODE=1 #{env} ./ex_manga_downloadr #{options}"
  end

  def glob(dir) do
    # Briefly sometimes generates paths with two /
    dir = String.replace(dir, "//", "/")

    Path.wildcard("#{dir}/**/*")
    |> Enum.reject(&File.dir?/1)
    |> Enum.map(&String.replace(&1, "#{dir}/", ""))
    |> Enum.sort
  end

  test "downloads from mangareader correctly" do
    dir = create_tmpdir("boku-wa-ookami")

    run_manga_downloadr "-u http://www.mangareader.net/boku-wa-ookami -d #{dir}"

    assert glob(dir) == [
      "boku-wa-ookami_1.pdf",
      "boku-wa-ookami_1/Ookami wa Boku 00001 - Page 00001.jpg",
      "boku-wa-ookami_1/Ookami wa Boku 00001 - Page 00002.jpg"
    ]
  end

  test "downloads from mangafox correctly" do
    dir = create_tmpdir("onepunch")

    run_manga_downloadr "-u http://mangafox.me/manga/onepunch_man/ -d #{dir}"

    assert glob(dir) == [
      "onepunch_1.pdf",
      "onepunch_1/00076-00001.jpg",
      "onepunch_1/00076-00002.jpg"
    ]
  end

  test "test mode succeeds" do
    dir = create_tmpdir("onepunch")

    run_manga_downloadr "--test", "TEST_DIRECTORY=#{dir}"

    assert glob(dir)== [
      "Onepunch-Man 00001 - Page 00001.jpg",
      "Onepunch-Man 00001 - Page 00002.jpg"
    ]
  end
end
