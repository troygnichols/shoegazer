defmodule Db.ScraperTest do
  use ExUnit.Case
  doctest Db.Scraper

  test "parse_video" do
    assert Db.Scraper.parse_video_id("http://youtube.com/foobar") == "foobar"
    assert Db.Scraper.parse_video_id("https://youtube.com/foobar") == "foobar"
    assert Db.Scraper.parse_video_id("http://youtu.be/foobar") == "foobar"
    assert Db.Scraper.parse_video_id("https://youtu.be/foobar") == "foobar"
    assert Db.Scraper.parse_video_id("https://vimeo.com/foobar") == nil
    assert Db.Scraper.parse_video_id("https://bubetube.com/foobar") == nil
  end
end
