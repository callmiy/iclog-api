defmodule Iclog.Factory.MealCommentStrategy do
  use ExMachina.Strategy, function_name: :create

  alias Iclog.Repo
  alias Iclog.Observable.Meal

  def handle_create(%{meal: %Meal{}, text: text} = record, _opts) do
    ca = Ecto.build_assoc record.meal, :comments, %{text: text}
    Repo.insert! ca
  end
end

defmodule Iclog.Factory.MealComment do
  use ExMachina
  use Iclog.Factory.MealCommentStrategy

  def comment_factory do
    %{text: sequence("nice-meal-")}
  end
end