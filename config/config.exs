use Mix.Config

config :shoegazer, Shoegazer.Repo,
  adapter: EctoMnesia.Adapter

config :shoegazer,
  ecto_repos: [Shoegazer.Repo]

config :mnesia, :dir, 'priv/data/mnesia'

config :ecto_mnesia,
  host: {:system, :atom, "MNESIA_HOST", Kernel.node()},
  storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :disc_copies}

import_config "secrets.exs"
