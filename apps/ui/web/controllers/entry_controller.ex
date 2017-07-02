defmodule Ui.EntryController do
  use Ui.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", entries: get_entries()
  end

  def show(conn, %{"id"=>id}) do
    render conn, "show.html", entry: fetch_entry(id)
  end

  def delete(conn, %{"id"=>id}) do
    delete_entry(id)
    redirect conn, to: entry_path(conn, :index)
  end

  defp get_entries do
    offset = 0
    %{records: records} = GenServer.call(:db, {:get_entries, offset})
    records
  end

  defp delete_entry(id) do
    GenServer.call(:db, {:delete_entry, :id, id})
  end

  defp fetch_entry(id) do
    GenServer.call(:db, {:fetch_entry, :id, id})
  end
end
