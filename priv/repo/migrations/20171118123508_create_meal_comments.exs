defmodule Iclog.Repo.Migrations.CreateMealComments do
  use Ecto.Migration

  def change do
    create table(:meal_comments) do
      add :comment_id, :integer, null: false # this is the foreign key
      add :text, :text, null: false

      timestamps()
    end
  end
end
