defmodule Db.API do
  use GenServer

  require Logger

  alias Db.{Entry,Repo}

  @options [
    name: :db,
    # debug: [:trace],
  ]

  def start_link do
    Logger.debug "DB API starting"
    GenServer.start_link(__MODULE__, [], @options)
  end

  def handle_call({:get_entries, offset, limit}, _from, state) do
    {:reply, get_entries(offset, limit), state}
  end

  def handle_call({:delete_entry, :id, id}, _from, state) do
    {:reply, delete_entry(:id, id), state}
  end

  def handle_call({:fetch_entry, field, value}, _from, state) do
    {:reply, fetch_entry(field, value), state}
  end

  def handle_call({:earliest_entry, opts}, _from, state) do
    {:reply, earliest_entry(opts), state}
  end

  def handle_call({:mark_entry_listened, id}, _from, state) do
    {:reply, mark_entry_listened(id), state}
  end

  def handle_call(:screen_name, _from, state) do
    {:reply, screen_name(), state}
  end

  def get_entries(offset \\ 0, limit \\ nil) do
    import Ecto.Query
    total = :mnesia.table_info(:entries, :size)
    records = Repo.all(
      from e in Entry, order_by: [asc: :posted_at])
    {records, current} = case limit do
      nil -> {records, total}
      _ -> {Enum.slice(offset, limit), limit + offset}
    end
    %{total: total, records: records, limit: limit, offset: offset, current: current}
  end

  def delete_entry(:id, id) do
    fetch_entry(:id, id)
    |> Repo.delete!()
  end

  def fetch_entry(field, value) do
    Repo.get_by!(Entry, [{field, value}])
  end

  def earliest_entry(opts \\ []) do
    import Ecto.Query
    query = Entry |> order_by([asc: :posted_at]) |> limit(1)
    query = case opts[:listened] do
      val when is_boolean(val) -> query |> where(listened: ^val)
      _ -> query
    end
    Repo.one(query)
  end

  def mark_entry_listened(id) do
    Repo.get(Entry, id)
    |> Entry.changeset(%{listened: true})
    |> Repo.update!()
  end

  def reset_listened do
    Repo.update_all(Entry, set: [listened: false])
  end

  def screen_name do
    Application.get_env(:db, :screen_name)
  end

end
