defmodule Shoegazer.Entry do
  use Ecto.Schema

  schema "entries" do
    field :twitter_id, :string
    field :url,        :string
    field :created_at, :utc_datetime
    field :posted_at,  :utc_datetime
    field :listened,   :boolean
  end

  def changeset(person, params \\ %{}) do
    fields = [:twitter_id, :url, :created_at, :posted_at, :listened]
    person
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.validate_required(fields)
  end
end
