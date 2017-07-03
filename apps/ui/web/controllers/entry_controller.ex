defmodule Ui.EntryController do
  use Ui.Web, :controller

  @default_page_size 10

  def index(conn, params) do
    {offset, limit} = get_paging_info(params)
    {records, meta} = get_entries(offset, limit)
    render conn, "index.html", entries: records, meta: meta
  end

  def show(conn, %{"id"=>id}) do
    render conn, "show.html", entry: fetch_entry(id)
  end

  def delete(conn, %{"id"=>id}) do
    delete_entry(id)
    redirect conn, to: entry_path(conn, :index)
  end

  defp get_entries(offset, limit) do
    GenServer.call(:db, {:get_entries, 0, nil})
    |> Map.pop(:records)
  end

  defp delete_entry(id) do
    GenServer.call(:db, {:delete_entry, :id, id})
  end

  defp fetch_entry(id) do
    GenServer.call(:db, {:fetch_entry, :id, id})
  end

  defp get_paging_info(%{"page"=>page, "per_page"=>per_page}) do
    page = String.to_integer(page) - 1
    per_page = String.to_integer(per_page)
    {page * per_page, per_page}
  end
  defp get_paging_info(_), do: {0, @default_page_size}
end
