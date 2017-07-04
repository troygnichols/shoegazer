defmodule Ui.PageController do
  use Ui.Web, :controller

  def index(conn, _params) do
    entry = get_earliest_unwatched_entry()
    conn |> redirect to: watch_path(conn, :watch, entry.id)
  end

  defp get_earliest_unwatched_entry do
    GenServer.call(:db, {:earliest_entry, listened: false})
  end

end
