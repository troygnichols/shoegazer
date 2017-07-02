defmodule Db.Mixfile do
  use Mix.Project

  def project do
    [app: :db,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [mod: {Db.Application, []},
     extra_applications: [
       :logger,
       :httpoison,
       :poison,
       :ecto_mnesia,
       :timex,
     ]]
  end

  defp deps do
    [
      {:oauther, "~> 1.1"},
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 3.0"},
      {:ecto_mnesia, github: "Nebo15/ecto_mnesia", ref: "0c872fd4"},
      {:timex, "~> 3.0"},
    ]
  end
end
