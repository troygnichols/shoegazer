defmodule Shoegazer.Scraper do
  use GenServer

  require Logger

  @options [
    name: :scraper,
    debug: [:trace],
  ]

  @poll_interval_ms 60 * 1000

  def start_link() do
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
    url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    params = [{"screen_name", "shoegazer_bot"}, {"count", 2}]
    creds = OAuther.credentials(Application.get_env(:shoegazer, :twitter))
    signed = OAuther.sign("get", url, params, creds)
    {header, req_params} = OAuther.header(signed)
    %{status_code: 200, body: body} = HTTPoison.get!(url, [header], params: req_params)
    Poison.decode!(body)
  end
end
