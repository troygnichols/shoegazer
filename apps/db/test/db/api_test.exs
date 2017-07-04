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

  test "delete entry" do
    import Ecto.Query
    Db.Repo.delete_all(Db.Entry)
    Db.Repo.insert!(%Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 2, url: "http://foo.bar", created_at: 0, posted_at: 1, listened: false})
    entry = Db.Repo.one(from e in Db.Entry, where: [twitter_id: 1])
    Db.API.delete_entry(:id, entry.id)
    assert 1 == Db.Repo.all(Db.Entry) |> Enum.count()
  end

  test "fetch by twitter id" do
    Db.Repo.delete_all(Db.Entry)
    Db.Repo.insert!(%Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 1, listened: false})
    found = Db.API.fetch_entry(:twitter_id, 2)
    assert "http://baz.qux" == found.url
  end

  test "earliest entry listened not specified" do
    Db.Repo.delete_all(Db.Entry)
    entry1 = %Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: true}
    entry2 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 1, listened: false}
    entry3 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 2, listened: false}
    Db.Repo.insert!(entry1)
    Db.Repo.insert!(entry2)
    Db.Repo.insert!(entry3)
    found = Db.API.earliest_entry()
    assert found.twitter_id == entry1.twitter_id
  end

  test "earliest entry listened true" do
    Db.Repo.delete_all(Db.Entry)
    entry1 = %Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: false}
    entry2 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 1, listened: true}
    entry3 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 2, listened: true}
    Db.Repo.insert!(entry1)
    Db.Repo.insert!(entry2)
    Db.Repo.insert!(entry3)
    found = Db.API.earliest_entry(listened: true)
    assert found.twitter_id == entry2.twitter_id
  end

  test "earliest entry listened false" do
    Db.Repo.delete_all(Db.Entry)
    entry1 = %Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: true}
    entry2 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 1, listened: false}
    entry3 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 2, listened: false}
    Db.Repo.insert!(entry1)
    Db.Repo.insert!(entry2)
    Db.Repo.insert!(entry3)
    found = Db.API.earliest_entry(listened: false)
    assert found.twitter_id == entry2.twitter_id
  end

  test "earliest entry with bad value" do
    Db.Repo.delete_all(Db.Entry)
    entry1 = %Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: true}
    entry2 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 1, listened: false}
    entry3 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 2, listened: false}
    Db.Repo.insert!(entry1)
    Db.Repo.insert!(entry2)
    Db.Repo.insert!(entry3)
    found = Db.API.earliest_entry(listened: :foobar)
    assert found.twitter_id == entry1.twitter_id
  end

  test "earliest entry with bad field" do
    Db.Repo.delete_all(Db.Entry)
    entry1 = %Db.Entry{twitter_id: 1, url: "http://foo.bar", created_at: 0, posted_at: 0, listened: true}
    entry2 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 1, listened: false}
    entry3 = %Db.Entry{twitter_id: 2, url: "http://baz.qux", created_at: 0, posted_at: 2, listened: false}
    Db.Repo.insert!(entry1)
    Db.Repo.insert!(entry2)
    Db.Repo.insert!(entry3)
    found = Db.API.earliest_entry(foobar: :bazqux)
    assert found.twitter_id == entry1.twitter_id
  end

  test "mark entry listened" do
    Db.Repo.delete_all(Db.Entry)
    Db.Repo.insert!( %Db.Entry{twitter_id: 1, url: "http://foo.bar", video_id: "foo", created_at: 0, posted_at: 0, listened: false})
    Db.Repo.insert!(%Db.Entry{twitter_id: 2, url: "http://baz.qux", video_id: "bar", created_at: 0, posted_at: 1, listened: false})
    entry = Db.Repo.get_by!(Db.Entry, twitter_id: 1)
    assert entry.listened == false
    Db.API.mark_entry_listened(entry.id)
    entry = Db.Repo.get_by!(Db.Entry, twitter_id: 1)
    assert entry.listened == true
  end

  test "next entry no filter" do
    Db.Repo.delete_all(Db.Entry)
    Db.Repo.insert!(%Db.Entry{twitter_id: 1, url: "http://foo.bar", video_id: "foo", created_at: 0, posted_at: 0, listened: true})
    Db.Repo.insert!(%Db.Entry{twitter_id: 2, url: "http://baz.qux", video_id: "bar", created_at: 0, posted_at: 1, listened: true})
    Db.Repo.insert!(%Db.Entry{twitter_id: 3, url: "http://bar.baz", video_id: "qux", created_at: 0, posted_at: 2, listened: true})
    entry = Db.Repo.get_by!(Db.Entry, twitter_id: 1)
    next = Db.API.next_entry(entry.id)
    assert next.twitter_id == 2
  end

  test "next entry with listened filter" do
    Db.Repo.delete_all(Db.Entry)
    Db.Repo.insert!(%Db.Entry{twitter_id: 1, url: "http://foo.bar", video_id: "foo", created_at: 0, posted_at: 0, listened: true})
    Db.Repo.insert!(%Db.Entry{twitter_id: 2, url: "http://baz.qux", video_id: "bar", created_at: 0, posted_at: 1, listened: true})
    Db.Repo.insert!(%Db.Entry{twitter_id: 3, url: "http://bar.baz", video_id: "qux", created_at: 0, posted_at: 2, listened: false})
    entry = Db.Repo.get_by!(Db.Entry, twitter_id: 1)
    next = Db.API.next_entry(entry.id, listened: false)
    assert next.twitter_id == 3
  end

  test "prev entry" do
    Db.Repo.delete_all(Db.Entry)
    Db.Repo.insert!(%Db.Entry{twitter_id: 1, url: "http://foo.bar", video_id: "foo", created_at: 0, posted_at: 0, listened: true})
    Db.Repo.insert!(%Db.Entry{twitter_id: 2, url: "http://baz.qux", video_id: "bar", created_at: 0, posted_at: 1, listened: true})
    Db.Repo.insert!(%Db.Entry{twitter_id: 3, url: "http://bar.baz", video_id: "qux", created_at: 0, posted_at: 2, listened: false})
    entry = Db.Repo.get_by!(Db.Entry, twitter_id: 2)
    next = Db.API.prev_entry(entry.id)
    assert next.twitter_id == 1
  end

end
