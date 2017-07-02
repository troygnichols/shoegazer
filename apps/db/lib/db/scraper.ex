defmodule Db.Scraper do
  use GenServer

  require Logger

  @options [
    name: :dbscraper,
    debug: [:trace],
  ]

  @poll_interval_ms 60 * 1000

  def start_link do
    Logger.debug "Db Scraper starting"
    GenServer.start_link(__MODULE__, [], @options)
  end

  def init(state) do
    Logger.debug "Db Scraper starting poll"
    {:ok, state} #, @poll_interval_ms}
  end

  def handle_info(:timeout, state) do
    pull_data()
    {:noreply, state, @poll_interval_ms}
  end

  def pull_data do
    case maybe_init_local_entries() do
      {:already_initialized, most_recent_entry} ->
        # sync local entries with twitter:
        # find newest entry and newest tweet
        # and get all tweets in between them,
        # saving them all as entries
        [last_tweet] = last_n_tweets(1)
        sync_tweets_with_entries(last_tweet, most_recent_entry)
      :did_initialize ->
        # initialized a new set of local entries
        # with some tweets, we're done for now
        :ok
    end
  end

  def entry_params_from_tweet(%{
    "id" => id,
    "entities"=> %{"urls" => urls},
    "created_at" => posted_at
  }) do
    url = case urls do
      [] -> nil
      [%{"url" => url}|_] -> url
    end
    unix_now = DateTime.utc_now() |> DateTime.to_unix()
    unix_posted_at = Timex.parse!(posted_at,
      "%a %b %d %H:%M:%S %z %Y", :strftime)
      |> DateTime.to_unix()
    %{twitter_id: id, url: url, listened: false,
      created_at: unix_now, posted_at: unix_posted_at}
  end

  def maybe_init_local_entries do
    case Db.Entry.most_recent() do
      nil ->
        Logger.debug "Initializing local entries, fetching tweets"
        entries = last_n_tweets(50)
        |> Enum.map(&entry_params_from_tweet/1)
        Db.Repo.insert_all(Db.Entry, entries)
        :did_initialize
      entry ->
        Logger.debug "Local entries already initialized, returning most recent: #{inspect entry}"
        {:already_initialized, entry}
    end
  end

  def last_n_tweets(n, max_id \\ nil),
    do: fetch_tweets(count: n, max_id: max_id)

  def fetch_tweets(params) do
    url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    creds = OAuther.credentials(Application.get_env(:db, :twitter))
    signed = OAuther.sign("get", url, make_params(params), creds)
    {header, req_params} = OAuther.header(signed)
    %{status_code: 200, body: body} = HTTPoison.get!(url, [header], params: req_params)
    Poison.decode!(body)
  end

  def make_params(params) do
    params
    |> Enum.reject(fn({_key, value}) -> is_nil(value) end)
    |> Keyword.merge([screen_name: "shoegazer_bot"])
    |> Enum.map(fn({key, value}) ->
      {to_string(key), to_string(value)}
    end)
  end

  # Starting from the newest entry twitter id from the database,
  # get 20 tweets at a time until we reach our newest_tweet's id
  def sync_tweets_with_entries(%{"id" => twt_id},
   %{twitter_id: entry_twt_id}) when entry_twt_id >= twt_id do
    Logger.debug "Sync complete"
  end
  def sync_tweets_with_entries(newest_tweet, newest_entry) do
    new_tweets = fetch_tweets(
      since_id: newest_entry.twitter_id,
      max_id: newest_tweet["id"], count: 20)

    entries = Enum.map(new_tweets, &entry_params_from_tweet/1)
    Db.Repo.insert_all(Db.Entry, entries)

    newest_entry_after_update = Enum.max_by(entries, &(&1.twitter_id))
    sync_tweets_with_entries(newest_tweet, newest_entry_after_update)
  end
end
