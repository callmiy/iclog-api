defmodule Iclog.Repo.Migrations.CreateSleepComments do
  use Ecto.Migration

  def change do
    create table(:sleep_comments) do
      add :comment_id, :integer, null: false # this is the foreign key to sleeps table
      add :text, :text, null: false

      timestamps()
    end
  end
end
