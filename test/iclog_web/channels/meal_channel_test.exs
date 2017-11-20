defmodule IclogWeb.MealChannelTest do
  use IclogWeb.ChannelCase

  import Iclog.MealTestHelper

  alias IclogWeb.MealChannel
  alias Iclog.Observable.Meal

  def init(_) do
    {query, params} = query(:paginated_meals, 1)

    {:ok, response, socket} =
    socket("user_id", %{some: :assign})
    |> subscribe_and_join(
        MealChannel,
        "meal:meal",
        %{"query" => query, "params" => params}
      )

    {:ok, socket: socket, socket_response: response}
  end

  def init_with_meals(_) do
    insert_list(11, :meal)
    {:ok, created: true}
  end

  describe "socket response" do
    setup [:init_with_meals, :init]

    test "successful response", %{socket_response: socket_response} do
      assert %{
        data: %{
          "paginatedMeals" => %{
            "entries" => _obs,
            "pagination" => %{
              "totalEntries" => 11,
              "pageNumber" => 1,
              "pageSize" => 10,
              "totalPages" => 2,
            }
          }
        }
      } = socket_response
    end
  end

  describe "new_meal" do
    setup :init

    test "replies with status ok and created meal, and broadcasts meal",
        %{socket: socket} do
      {query, params} = mutation(:meal)

      ref = push socket, "new_meal", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{"id" => _}
      )

      assert_push(
        "meal_created",
        %{data:  %{"meal" => %{"id" => _, "comments" => _}}}
      )
    end

    test "replies with status error", %{socket: socket} do
      {query, params} = mutation(:meal_invalid)

      ref = push socket, "new_meal", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :error,
        %{errors: _}
      )
    end
  end

  describe "list_meals" do
    setup :init

    test "replies with status ok and meals", %{socket: socket} do
      insert(:meal)
      {query, params} = query(:paginated_meals, 1)

      ref = push socket, "list_meals", %{
        "query" => query,
        "params" => params
      }

      assert_reply ref, :ok, %{data: %{"paginatedMeals" => %{"entries" => _}}}
    end
  end

  describe "get_meal" do
    setup :init

    test "replies with status ok and meal", %{socket: socket} do
      meal = insert(:meal)
      {query, params} = query(:meal, meal.id)

      ref = push socket, "get_meal", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{data:  %{"meal" => %{"id" => _, "comments" => _}}}
      )
    end

    test "replies with status error", %{socket: socket} do
      {query, params} = query(:meal, 0)

      ref = push socket, "new_meal", %{
        "query" => query,
        "params" => params
      }

      assert_reply ref, :error, %{errors: _}
    end
  end

  describe "update_meal" do
    setup :init

    test "replies with status ok and updated meal, and broadcasts meal",
        %{socket: socket} do

      %Meal{
        id: id,
        meal: meal,
        time: _time
      } = insert(:meal)

      query = mutation(:meal_update)
      params = %{
        "id" => Integer.to_string(id),
        "meal" => "#{meal}-updated"
      }

      ref = push socket, "update_meal", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{data:  %{"mealUpdate" => %{"id" => _, "comments" => _}}}
      )

      assert_push(
        "meal_updated",
        %{"id" => _id, "time" => _, "meal" => _}
      )
    end

    test "replies with status error", %{socket: socket} do
      query = mutation(:meal_update)
      params = %{
        "id" => "0",
        "meal" => "",
        "time" => "",
      }

      ref = push socket, "update_meal", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :error,
        %{errors: _}
      )
    end
  end
end