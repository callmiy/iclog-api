defmodule IclogWeb.Schema.Sleep do
  @moduledoc """
  Schema types
  """

  use Absinthe.Schema.Notation

  alias Iclog.Observable.Sleep
  alias IclogWeb.ChangesetView
  alias Phoenix.View

  @desc "A sleep object"
  object :sleep do
    field :id, :id
    field :start, :i_s_o_datetime
    field :end, :i_s_o_datetime
    field :comments, list_of(:generic_comment)
    field :inserted_at, :i_s_o_datetime
    field :updated_at, :i_s_o_datetime
  end

  @desc "List of sleeps, but paginated"
  object :paginated_sleep do
    field :entries, list_of(:sleep)
    field :pagination, :pagination
  end

  object :sleep_queries do
    field :sleep, type: :sleep do
      arg :id, non_null(:id)

      resolve fn(%{id: id}, _info) ->
        case Sleep.get(id) do
          nil  ->
            {:error, "Sleep with id: #{id} not found!"}

          sleep ->
            {:ok, sleep}
        end
      end
    end

    field :sleeps, list_of(:sleep) do
      resolve fn(_args, _info) ->
        {:ok, Sleep.list_all()}
      end
    end

    field :paginated_sleeps, :paginated_sleep do
      arg :pagination, non_null(:pagination_params)

      resolve fn(args, _info) ->
        pagination_params = Map.get(args, :pagination, %{})
        {:ok, Sleep.list_all(pagination_params)}
      end
    end
  end

  @desc "Create a sleep"
  object :sleep_mutations do

    @desc "Create a sleep and may be with comment simulatenously"
    field :sleep, type: :sleep do
      arg :start, non_null(:string)
      arg :end, :string
      arg :comment, :comment_params

      resolve fn(params, _) ->
        with {:ok, data} <- Sleep.create(params) do
          {:ok, data}
        else
          {:error, changeset} ->
            {:error,  changeset_errors_to_string(changeset)}
        end
      end
    end

    @desc "Update a sleep"
    field :sleep_update, type: :sleep do
      arg :id, non_null(:id)
      arg :start, :string
      arg :end, :string
      arg :comment, :comment_params

      resolve fn(args, _) ->
        {id, params} = Map.pop(args, :id)

        case Sleep.get(id) do
          nil ->
            {:error, message: "Sleep with id: #{id} does not exist!"}

          sleep ->
            with {:ok, data} <- Sleep.update(sleep, params) do
              {:ok, data}
            else
              {:error, changeset} ->
                {:error,  changeset_errors_to_string(changeset)}
            end
        end
      end
    end

    @desc "Create a comment for a sleep"
    field :sleep_comment, type: :generic_comment do
      arg :sleep_id, non_null(:id)
      arg :text, non_null(:string)

      resolve fn(%{sleep_id: id, text: text}= _params, _) ->
        case Sleep.get(id) do
          nil ->
            {:error, "Sleep with id: #{id} not found!"}
          sleep ->
            Sleep.create_comment(sleep, %{text: text})
        end
      end
    end
  end

  defp changeset_errors_to_string(%Ecto.Changeset{} =  changeset) do
    Enum.map_join(
      View.render(ChangesetView, "error.json", changeset: changeset)[:errors],
      "|",
      fn({k, v}) ->
        value = Enum.join(v, ",")
        "#{k}:#{value}"
      end)
  end
end
