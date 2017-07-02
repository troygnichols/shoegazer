defmodule Ui.PageController do
  use Ui.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", entry: get_entry()
  end

  defp get_entry do
    GenServer.call(:db, {:earliest_entry, listened: false})
  end
end
