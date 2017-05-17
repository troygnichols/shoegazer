defmodule Shoegazer.Entry do
  use Ecto.Schema

  schema "entries" do
    field :twitter_id, :string
    field :url,        :string
    field :created_at, :integer
    field :posted_at,  :integer
    field :listened,   :boolean
  end

  def changeset(person, params \\ %{}) do
    fields = [:twitter_id, :url, :created_at, :posted_at, :listened]
    person
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.validate_required(fields)
  end

  def most_recent do
    require Ecto.Query
    Ecto.Query.from(e in Shoegazer.Entry,
      order_by: [desc: e.posted_at], limit: 1)
      |> Shoegazer.Repo.one()
  end
end
