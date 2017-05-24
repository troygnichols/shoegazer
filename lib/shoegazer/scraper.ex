defmodule Shoegazer.Scraper do
  use GenServer

  require Logger

  @options [
    name: :scraper,
    debug: [:trace],
  ]

  @poll_interval_ms 60 * 1000

  def start_link do
    Logger.debug "Starting Shoegazer.Scraper"
    GenServer.start_link(__MODULE__, [], @options)
  end

  def init(state) do
    Logger.debug "Shoegazer.Scraper starting poll"
    {:ok, state}#, @poll_interval_ms}
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
        cond do
          last_tweet.id > most_recent_entry.twitter_id ->
            # TODO: wrap transaction around this?
            sync_tweets_with_entries(last_tweet, most_recent_entry)
          true ->
            Logger.debug "No new tweets, nothing to do"
        end
        :ok
      :did_initialize ->
        # initialized a new set of local entries
        # with some tweets, we're done for now
        :ok
    end
  end

  def maybe_init_local_entries do
    case Shoegazer.Entry.most_recent() do
      nil ->
        Logger.debug "Initializing local entries, fetching tweets"
        entries = last_n_tweets(50)
        |> Enum.map(fn(%{"id_str" => id, "entities"=> %{"urls" => urls},
          "created_at" => posted_at}) ->
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
        end)
        Shoegazer.Repo.insert_all(Shoegazer.Entry, entries)
        :did_initialize
      entry ->
        Logger.debug "Local entries already initialized, returning most recent: #{inspect entry}"
        {:already_initialized, entry}
    end
  end

  def last_n_tweets(n, max_id \\ nil) do
    url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    params = [{"screen_name", "shoegazer_bot"}, {"count", n}]
    params = case max_id do
      nil -> params
      max_id -> params ++ [{"max_id", max_id}]
    end
    creds = OAuther.credentials(Application.get_env(:shoegazer, :twitter))
    signed = OAuther.sign("get", url, params, creds)
    {header, req_params} = OAuther.header(signed)
    %{status_code: 200, body: body} = HTTPoison.get!(url, [header], params: req_params)
    Poison.decode!(body)
  end

  def sync_tweets_with_entries(%{id: twt_id},
   %Shoegazer.Entry{twitter_id: entry_twt_id}) when entry_twt_id >= twt_id do
    Logger.debug "Sync complete"
  end
  def sync_tweets_with_entries(newest_tweet, newest_entry, chunk_size \\ 20) do
    tweets = [newest_tweet] ++ last_n_tweets(chunk_size, newest_tweet.id)
    last_tweet = List.last(tweets)

    # starting from newest_entry twitter id (since_id param for twitter API)
    # get 20 tweets at a time until we reach our newest_tweet's id
    # then stop

    for tweet <- tweets do

    end


    sync_tweets_with_entries(last_tweet, newest_entry)
  end
end
