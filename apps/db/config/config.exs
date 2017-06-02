use Mix.Config

config :db, Db.Repo,
  adapter: EctoMnesia.Adapter

config :db,
  ecto_repos: [Db.Repo]

import_config "secrets.exs"

import_config "#{Mix.env}.exs"
