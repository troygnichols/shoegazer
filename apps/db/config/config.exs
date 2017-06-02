use Mix.Config

config :mnesia, :dir, [__DIR__, "..", "priv", "data", "mnesia",
  Mix.env |> to_string()]
  |> Path.join()
  |> Path.expand()
  |> to_charlist()

config :db, Db.Repo,
  adapter: EctoMnesia.Adapter

config :db,
  ecto_repos: [Db.Repo]

import_config "secrets.exs"

import_config "#{Mix.env}.exs"
