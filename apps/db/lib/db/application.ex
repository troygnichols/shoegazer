defmodule Db.Application do
  use Application

  import Supervisor.Spec

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Logger.debug "starting db application"

    children = [
      worker(Db.Repo, []),
      worker(Db.Scraper, []),
    ]

    opts = [
      strategy: :one_for_one,
      debug: [:trace],
      name: :db
    ]

    Supervisor.start_link(children, opts)
  end
end
