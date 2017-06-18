defmodule EndToEndTest do
  @moduletag [:slow]

  use ExUnit.Case

  def create_tmpdir(dir) do
    {:ok, tmpdir} = Briefly.create(directory: true)

    tmpdir |> Path.join(dir)
  end

  def run_manga_downloadr(url, dir) do
    import Porcelain, only: [shell: 1]

    shell "mix escript.build"
    shell "END_TO_END_TEST_MODE=1 ./ex_manga_downloadr -u #{url} -d #{dir}"
  end

  test "downloads from mangareader correctly" do
    dir = create_tmpdir("boku-wa-ookami")

    run_manga_downloadr "http://www.mangareader.net/boku-wa-ookami", dir

    assert File.exists?("#{dir}/boku-wa-ookami_1.pdf")
    assert File.exists?("#{dir}/boku-wa-ookami_1/Ookami wa Boku 00001 - Page 00001.jpg")
    assert File.exists?("#{dir}/boku-wa-ookami_1/Ookami wa Boku 00001 - Page 00002.jpg")
  end

  test "downloads from mangafox correctly" do
    dir = create_tmpdir("onepunch")

    run_manga_downloadr "http://mangafox.me/manga/onepunch_man/", dir

    assert File.exists?("#{dir}/onepunch_1.pdf")
    assert File.exists?("#{dir}/onepunch_1/00076-00001.jpg")
    assert File.exists?("#{dir}/onepunch_1/00076-00002.jpg")
  end
end
