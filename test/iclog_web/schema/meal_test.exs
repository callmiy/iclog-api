defmodule IclogWeb.Schema.MealTest do
  use Iclog.DataCase
  import Iclog.MealTestHelper

  alias Iclog.Observable.Meal
  alias Iclog.Comment
  alias IclogWeb.Schema

  describe "query" do
    test "meal returns meal" do
      %Meal{
        id: id_,
        meal: meal,
        time: _time_
      } = meal_ = insert(:meal)

      %Comment{
        id: comment_id_,
        text: text
      } = MealCommentFactory.create :comment, meal: meal_

      id = Integer.to_string id_
      comment_id = Integer.to_string comment_id_

      {query, params} = query(:meal, id_)

      assert {:ok, %{
          data: %{
            "meal" => %{
              "id" => ^id,
              "meal" => ^meal,
              "time" => _,
              "insertedAt" => _,
              "updatedAt" => _,
              "comments" => [%{
                "id" => ^comment_id,
                "text" => ^text,
                "insertedAt" => _,
                "updatedAt" => _,
              }]
            }
          }
        }
      } = Absinthe.run(query, Schema, variables: params)
    end

    test "meal returns error" do
      {query, params} = query(:meal, 0)

      assert {:ok, %{
          errors: [%{message: _}]
        }
      } = Absinthe.run(query, Schema, variables: params)
    end

    test "meals" do
      %Meal{
        id: id_,
        meal: meal,
        time: _time_
      } = meal_ = insert(:meal)

      _comments = MealCommentFactory.create_list 3, :comment, meal: meal_

      id = Integer.to_string id_

      assert {:ok, %{
          data: %{
            "meals" => [%{
              "id" => ^id,
              "meal" => ^meal,
              "time" => _,
              "insertedAt" => _,
              "updatedAt" => _,
              "comments" => comments
            }]
          }
        }
      } = Absinthe.run(query(:meals), Schema)

      assert length(comments) == 3
    end

    test ":paginated_meals page number 1 succeeds" do
      insert_list(11, :meal)
      {query, params} = query(:paginated_meals, 1)

      {:ok, %{
          data: %{
            "paginatedMeals" => %{
              "entries" => obs,
              "pagination" => %{
                "totalEntries" => 11,
                "pageNumber" => 1,
                "pageSize" => 10,
                "totalPages" => 2,
              }
            }
          }
        }
      } = Absinthe.run(query, Schema, variables: params)

      assert length(obs) == 10

      assert %{
        "id" => _,
        "meal" => _,
        "time" => _,
        "insertedAt" => _,
        "updatedAt" => _,
        "comments" => []
      } = List.first(obs)
    end

    test ":paginated_meals page number 2 succeeds" do
      insert_list(11, :meal)
      |> Enum.each(&MealCommentFactory.create(:comment, meal: &1))

      {query, params} = query(:paginated_meals, 2)

      {:ok, %{
          data: %{
            "paginatedMeals" => %{
              "entries" => obs,
              "pagination" => %{
                "totalEntries" => 11,
                "pageNumber" => 2,
                "pageSize" => 10,
                "totalPages" => 2,
              }
            }
          }
        }
      } = Absinthe.run(query, Schema, variables: params)

      assert [%{
        "id" => _,
        "meal" => _,
        "time" => _,
        "insertedAt" => _,
        "updatedAt" => _,
        "comments" => [%{
          "id" => _,
          "text" => _,
          "insertedAt" => _,
        }]
      }] = obs
    end
  end

  describe "mutation" do
    test ":meal succeeds" do
      {query, params} = mutation(:meal)

      assert {:ok, %{data: %{"meal" => %{"id" => _, "comments" => []} } }} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":meal fails" do
      {query, params} = mutation(:meal_invalid)

      assert {:ok, %{errors: _}} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":meal with comment succeeds" do
      {query, params} = mutation(:meal_with_comment)

      assert {
        :ok, %{
          data: %{
            "meal" => %{
              "id" => _,
              "comments" => [%{
                "text" => text,
              }]
            }
          }
        }
      } = Absinthe.run(query, Schema, variables: params)

      assert text == "Der jollof smerks gut!"
    end

    test ":meal_comment succeeds" do
      %Meal{id: id} = insert :meal
      {query, params} = mutation(:meal_comment, id)

      assert {:ok, %{data: %{"mealComment" => %{"id" => _} } }} =
      Absinthe.run(query, Schema, variables: params)
    end

    test ":meal_comment errors" do
      {query, params} = mutation(:meal_comment, 0)

      assert {:ok, %{errors: _}} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":meal_update succeeds" do
      %Meal{
        id: id_,
        meal: meal_,
        time: time_
      } = meal_struct = insert(:meal)

      id = Integer.to_string id_
      meal = "#{meal_}-updated"

      time = time_
      |> Timex.shift(minutes: 5)
      |> Timex.format!("{ISO:Extended:Z}")

      %Comment{
        id: comment_id_,
        text: text
      } = MealCommentFactory.create :comment, meal: meal_struct

      comment_id = Integer.to_string comment_id_

      params = %{
        "id" => id,
        "meal" => meal,
        "time" => time,
      }

      assert {:ok,
            %{data:
              %{"mealUpdate" =>
                %{
                    "id" =>^id,
                    "meal" => ^meal,
                    "insertedAt" => _,
                    "updatedAt" => _,
                    "comments" => [%{
                      "id" => ^comment_id, "text" => ^text,
                    }]
                }
              }
            }
        } =
      Absinthe.run(mutation(:meal_update), Schema, variables: params)
    end

    test ":meal_update errors" do
      params = %{
        "id" => "0",
        "meal" => "",
        "time" => "",
      }

      assert {:ok, %{errors: _}} =
        Absinthe.run(mutation(:meal_update), Schema, variables: params)
    end

    test ":meal_update with comment succeeds" do
      %Meal{
        id: id_,
        meal: meal_
      } = meal_struct = insert(:meal)

      id = Integer.to_string id_
      meal = "#{meal_}-updated"

      MealCommentFactory.create :comment, meal: meal_struct

      params = %{
        "id" => id,
        "meal" => meal,
        "comment" => %{
          "text" => "This is another comment"
        }
      }

      assert {:ok,
            %{data:
              %{"mealUpdate" =>
                %{
                    "id" =>^id,
                    "meal" => ^meal,
                    "insertedAt" => _,
                    "updatedAt" => _,
                    "comments" => comments
                }
              }
            }
        } =
      Absinthe.run(mutation(:meal_update_with_comment), Schema, variables: params)

      assert length(comments) == 2
      assert %{"text" => "This is another comment"} = List.first(comments)
    end
  end
end
