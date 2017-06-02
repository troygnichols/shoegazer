use Mix.Config

config :ecto_mnesia,
  host: {:system, :atom, "MNESIA_HOST", Kernel.node()}, storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :disc_copies}
