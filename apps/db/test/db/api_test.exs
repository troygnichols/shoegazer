defmodule Db.APITest do
  use ExUnit.Case
  doctest Db.API

  test "get entries with limit" do
    Db.Repo.delete_all(Db.Entry)
    Db.Repo.insert!(%Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 2, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 3, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    %{total: total, records: records, limit: limit, offset: offset} = Db.API.get_entries(0, 2)
    assert Enum.count(records) == 2
    assert limit == 2
    assert offset == 0
  end

  test "entries with offset" do
    Db.Repo.delete_all(Db.Entry)
    Db.Repo.insert!(%Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 2, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 3, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 4, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    %{total: total, records: records, limit: limit, offset: offset} = Db.API.get_entries(1, 2)
    assert Enum.count(records) == 2
    assert limit == 2
    assert offset == 1
    assert [3, 2] == records |> Enum.map(&(&1.twitter_id))
  end

  test "sort ascending" do
    Db.Repo.delete_all(Db.Entry)
    Db.Repo.insert!(%Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 2, url: "http://foo.bar", created_at: 0, posted_at: 1, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 3, url: "http://foo.bar", created_at: 0, posted_at: 2, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 4, url: "http://foo.bar", created_at: 0, posted_at: 3, listened: false})
    %{total: total, records: records, limit: limit, offset: offset} = Db.API.get_entries(0, 2, :asc)
    assert Enum.count(records) == 2
    assert limit == 2
    assert offset == 0
    assert [1, 2] == records |> Enum.map(&(&1.twitter_id))
  end
end
