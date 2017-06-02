defmodule Db.Entry do
  use Ecto.Schema

  schema "entries" do
    field :twitter_id, :integer
    field :url,        :string
    field :created_at, :integer
    field :posted_at,  :integer
    field :listened,   :boolean
  end

  def changeset(entry, params \\ %{}) do
    fields = [:twitter_id, :url, :created_at, :posted_at, :listened]
    entry
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.validate_required(fields)
  end

  def most_recent do
    require Ecto.Query
    Ecto.Query.from(e in Db.Entry,
      order_by: [desc: e.posted_at], limit: 1)
      |> Db.Repo.one()
  end
end
