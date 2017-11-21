defmodule Iclog.MealTestHelper do

  def query(:meals) do
    """
    {
      meals {
        id
        meal
        time
        insertedAt
        updatedAt
        comments {
          id
          text
          insertedAt
          updatedAt
        }
      }
    }
    """
  end
  def query(:meal, id) do
    query = """
      query ($id: ID!) {
        meal (id: $id) {
          id
          meal
          time
          insertedAt
          updatedAt
          comments {
            id
            text
            insertedAt
            updatedAt
          }
        }
      }
    """

    params = %{"id" => Integer.to_string(id)}
    {query, params}
  end
  def query(:paginated_meals, page_number) do
    query = """
      query ($pagination: PaginationParams!) {
        paginatedMeals(
          pagination: $pagination
        ) {
            entries {
              id
              meal
              time
              insertedAt
              updatedAt
              comments {
                id
                text
                insertedAt
                updatedAt
              }
            }
            pagination {
              pageNumber
              pageSize
              totalPages
              totalEntries
            }
        }
      }
    """

    params = %{"pagination" => %{
      "page" => page_number
    }}

    {query, params}
  end
  def mutation(:meal) do
    query = """
      mutation ($meal: String!, $time: String!) {
        meal(meal: $meal, time: $time) {
          id
          meal
          time
          insertedAt
          updatedAt
          comments {
            id
            text
            insertedAt
          }
        }
      }
    """

    params = %{
      "meal" => "jollof rice",
      "time" => Timex.format!( Timex.now(), "{ISO:Extended:Z}")
    }

    {query, params}
  end
  def mutation(:meal_with_comment) do
    query = """
      mutation ($meal: String!, $time: String!, $comment: Comment) {
        meal(meal: $meal, time: $time, comment: $comment) {
          id
          meal
          time
          insertedAt
          updatedAt
          comments {
            id
            text
            insertedAt
          }
        }
      }
    """

    params = %{
      "meal" => "jollof rice",
      "time" => Timex.format!( Timex.now(), "{ISO:Extended:Z}"),
      "comment" => %{"text" => "Der jollof smerks gut!"}
    }

    {query, params}
  end
  def mutation(:meal_invalid) do
    query = """
      mutation ($meal: String!, time: String!) {
        meal(meal: $meal, time: $time) {
          id
          meal
          time
          insertedAt
          updatedAt
        }
      }
    """

    params = %{
      "meal" => "jollof rice",
    }

    {query, params}
  end
  def mutation(:meal_update) do
    """
      mutation ($id: ID!, $meal: String, $time: String) {
        mealUpdate (id: $id, meal: $meal, time: $time) {
          id
          meal
          time
          insertedAt
          updatedAt
          comments {
            id
            text
            insertedAt
            updatedAt
          }
        }
      }
    """
  end
  def mutation(:meal_update_with_comment) do
    """
      mutation ($id: ID!, $meal: String, $time: String, $comment: Comment) {
        mealUpdate(id: $id, meal: $meal, time: $time, comment: $comment) {
          id
          meal
          time
          insertedAt
          updatedAt
          comments {
            id
            text
            insertedAt
          }
        }
      }
    """
  end
  def mutation(:meal_comment, id) do
    query = """
      mutation ($mealId: ID!, $text: String!) {
        mealComment (mealId: $mealId, text: $text) {
          id
          text
          insertedAt
          updatedAt
        }
      }
    """

    params = %{
      "mealId" => (Integer.to_string id),
      "text" => "Meal was so nice..."
    }

    {query, params}
  end
end