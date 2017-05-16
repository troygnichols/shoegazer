defmodule Shoegazer do
  use Application

  import Supervisor.Spec

  require Logger

  def start(_type, _args) do
    Logger.debug "starting application"
    Supervisor.start_link(__MODULE__, [name: :fw])
  end

  def init(_) do
    Logger.debug "Initializing application"

    children = [
      worker(Shoegazer.Repo, []),
      worker(Shoegazer.Scraper, []),
    ]
    opts = [
      strategy: :one_for_one,
      debug: [:trace],
    ]
    supervise(children, opts)
  end
end
