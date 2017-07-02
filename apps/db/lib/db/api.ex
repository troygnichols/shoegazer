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

  def handle_call(:screen_name, _from, state) do
    {:reply, screen_name(), state}
  end

  def get_entries(offset \\ 0, limit \\ nil, sort_dir \\ :desc) do
    import Ecto.Query
    limit = limit || @max_limit
    records = Repo.all(
      from e in Entry, order_by: [{^sort_dir, e.posted_at}])
      |> Enum.slice(offset, limit)
    total = :mnesia.table_info(:entries, :size)
    %{total: total, records: records, limit: limit, offset: offset, current: offset + limit}
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
    Db.Repo.one(query)
  end

  def screen_name do
    Application.get_env(:db, :screen_name)
  end

end
