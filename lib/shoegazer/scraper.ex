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

  defp pull_data do
    Logger.debug "Pulling data from twitter"
    creds = OAuther.credentials(Application.get_env(:shoegazer, :twitter))
  end
end
