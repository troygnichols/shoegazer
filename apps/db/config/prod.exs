use Mix.Config

config :mnesia, :dir, 'priv/data/mnesia/prod'

config :ecto_mnesia,
  host: {:system, :atom, "MNESIA_HOST", Kernel.node()}, storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :disc_copies}
