use Mix.Config

config :shoegazer, Shoegazer.Repo,
  adapter: EctoMnesia.Adapter

config :shoegazer,
  ecto_repos: [Shoegazer.Repo]

import_config "secrets.exs"

import_config "#{Mix.env}.exs"
