defmodule Shoegazer.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :twitter_id, :string
      add :url,        :string
      add :created_at, :utc_datetime
      add :posted_at,  :utc_datetime
      add :listened,   :boolean
    end
  end
end
