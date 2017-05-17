defmodule Shoegazer.EntryTest do
  use ExUnit.Case
  doctest Shoegazer.Entry

  test "most_recent_entry returns nil when no enties" do
    Shoegazer.Repo.delete_all(Shoegazer.Entry)
    assert nil == Shoegazer.Entry.most_recent()
  end

  test "most_recent_entry returns expected entry" do
    new = 1231231232
    sorta_old = 1231231231
    very_old = 0
    now = DateTime.utc_now() |> DateTime.to_unix()
    test_data = [
      %{twitter_id: "3", url: "https://example.com", created_at: now, posted_at: sorta_old, listened: false},
      %{twitter_id: "4", url: "https://example.com", created_at: now, posted_at: new, listened: false},
      %{twitter_id: "5", url: "https://example.com", created_at: now, posted_at: very_old, listened: false},
    ]
    Shoegazer.Repo.insert_all(Shoegazer.Entry, test_data)
    assert Shoegazer.Entry.most_recent().twitter_id == "4"
  end
end
