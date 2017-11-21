defmodule IclogWeb.Schema.Meal do
  @moduledoc """
  Schema types
  """

  use Absinthe.Schema.Notation

  alias Iclog.Observable.Meal
  alias IclogWeb.ChangesetView
  alias Phoenix.View

  @desc "A meal comment"
  object :meal_comment do
    field :id, :id
    field :text, :string
    # field :meal, :meal -- may be later if required
    field :inserted_at, :i_s_o_datetime
    field :updated_at, :i_s_o_datetime
  end

  @desc "A meal"
  object :meal do
    field :id, :id
    field :meal, :string
    field :time, :i_s_o_datetime
    field :comments, list_of(:meal_comment)
    field :inserted_at, :i_s_o_datetime
    field :updated_at, :i_s_o_datetime
  end

  @desc "List of observations, but paginated"
  object :paginated_meal do
    field :entries, list_of(:meal)
    field :pagination, :pagination
  end

  object :meal_query do
    field :meal, type: :meal do
      arg :id, non_null(:id)

      resolve fn(%{id: id}, _info) ->
        case Meal.get(id) do
          nil  ->
            {:error, "Meal with id: #{id} not found!"}

          meal ->
            {:ok, meal}
        end
      end
    end

    field :meals, list_of(:meal) do

      resolve fn(_args, _info) ->
        {:ok, Meal.list_all()}
      end
    end

    field :paginated_meals, :paginated_meal do
      arg :pagination, non_null(:pagination_params)

      resolve fn(args, _info) ->
        pagination_params = Map.get(args, :pagination, nil)
        {:ok, Meal.list_all(pagination_params)}
      end
    end
  end

  input_object :comment do
    field :text, non_null(:string)
  end

  @desc "Create a meal"
  object :meal_mutations do

    @desc "Create a meal and may be with comment simulatenously"
    field :meal, type: :meal do
      arg :meal, non_null(:string)
      arg :time, non_null(:string)
      arg :comment, :comment

      resolve fn(params, _) ->
        with {:ok, data} <- Meal.create(params) do
          {:ok, data} # {:ok, %{data: ..}}
        else
          {:error, changeset} ->
            {:ok,  View.render(ChangesetView, "error.json", changeset: changeset)} # {:ok, %{errors: ....}}
        end
      end
    end

    @desc "Update a meal"
    field :meal_update, type: :meal do
      arg :id, non_null(:id)
      arg :meal, :string
      arg :time, :string
      arg :comment, :comment

      resolve fn(args, _) ->
        {id, params} = Map.pop(args, :id)

        case Meal.get(id) do
          nil ->
            message = "Meal with id: #{id} does not exist!"
            {:error, message: message, id: message}

          meal ->
            with {:ok, data} <- Meal.update(meal, params) do
              {:ok, data}
            else
              {:error, changeset} ->
                {:error,  View.render(ChangesetView, "error.json", changeset: changeset)}
            end
        end
      end
    end

    @desc "Create a comment for a meal"
    field :meal_comment, type: :meal_comment do
      arg :meal_id, non_null(:id)
      arg :text, non_null(:string)

      resolve fn(%{meal_id: id, text: text}= _params, _) ->
        case Meal.get(id) do
          nil ->
            {:error, "Meal with id: #{id} not found!"}
          meal ->
            Meal.create_comment(meal, %{text: text})
        end
      end
    end
  end
end
