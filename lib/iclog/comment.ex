defmodule Iclog.Comment do
  @moduledoc false

  use Ecto.Schema

  @timestamps_opts [
    type: Timex.Ecto.DateTime,
    autogenerate: {Timex.Ecto.DateTime, :autogenerate, []}
  ]

  schema "abstract table: comments" do
    # This will be used by associations on each "concrete" table
    field :comment_id, :integer # this will be the ID of the parent table
    field :text, :string

    timestamps()
  end
end