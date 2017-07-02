defmodule Db.API do
  use GenServer

  require Logger

  alias Db.{Entry,Repo}

  @options [
    name: :db,
    # debug: [:trace],
  ]

  @max_limit 200

  def start_link do
    Logger.debug "DB API starting"
    GenServer.start_link(__MODULE__, [], @options)
  end

  def handle_call({:get_entries, offset}, _from, state) do
    {:reply, get_entries(offset), state}
  end

  def handle_call({:delete_entry, :id, id}, _from, state) do
    {:reply, delete_entry(:id, id), state}
  end

  def handle_call({:fetch_entry, field, value}, _from, state) do
    {:reply, fetch_entry(field, value), state}
  end

  def handle_call(:screen_name, _from, state) do
    {:reply, screen_name(), state}
  end

  def get_entries(offset \\ 0, limit \\ @max_limit, sort_dir \\ :desc) do
    import Ecto.Query
    records = Repo.all(
      from e in Entry, order_by: [{^sort_dir, e.posted_at}])
      |> Enum.slice(offset, limit)
    total = :mnesia.table_info(:entries, :size)
    %{total: total, records: records, limit: limit, offset: offset}
  end

  def delete_entry(:id, id) do
    fetch_entry(:id, id)
    |> Repo.delete!()
  end

  def fetch_entry(field, value) do
    Repo.get_by!(Entry, [{field, value}])
  end

  def screen_name do
    Application.get_env(:db, :screen_name)
  end
end
