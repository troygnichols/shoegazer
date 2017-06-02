use Mix.Config

config :mnesia, :dir, 'priv/data/mnesia/test'

config :ecto_mnesia,
  host: {:system, :atom, "MNESIA_HOST", Kernel.node()}, storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :ram_copies}
