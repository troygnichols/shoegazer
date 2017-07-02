defmodule Ui.EntryControllerTest do
  use Ui.ConnCase

  alias Ui.Entry
  @valid_attrs %{created_at: 42, listened: true, posted_at: 42, twitter_id: 42, url: "some content"}
  @invalid_attrs %{}

end
