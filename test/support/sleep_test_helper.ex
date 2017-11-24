defmodule Iclog.SleepTestHelper do

  alias Iclog.TestHelper

  @query_sleep """
              {
                sleeps {
                  id
                  start
                  end
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

    @query_sleeps """
                  query ($id: ID!) {
                    sleep (id: $id) {
                      id
                      start
                      end
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

  def query(:sleeps) do
    @query_sleep
  end
  def query(:sleep, id) do
    {@query_sleeps, %{"id" => "#{id}"}}
  end
  def query(:paginated_sleeps, page_number) do
    query = """
      query ($pagination: PaginationParams!) {
        paginatedSleeps(
          pagination: $pagination
        ) {
            entries {
              id
              start
              end
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

    params = %{"pagination" => %{"page" => page_number}}
    {query, params}
  end

  def mutation(:sleep_update) do
    """
      mutation ($id: ID!, $start: String, $end: String) {
        sleepUpdate (id: $id, start: $start, end: $end) {
          id
          start
          end
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
  def mutation(:sleep_update_with_comment) do
    """
      mutation ($id: ID!, $start: String, $end: String, $comment: Comment) {
        sleepUpdate(id: $id, start: $start, end: $end, comment: $comment) {
          id
          start
          end
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
  def mutation(:sleep_comment, id) do
    query = """
      mutation ($sleepId: ID!, $text: String!) {
        sleepComment (sleepId: $sleepId, text: $text) {
          id
          text
          insertedAt
          updatedAt
        }
      }
    """

    params = %{
      "sleepId" => "#{id}", "text" => "Nice sleep."
    }

    {query, params}
  end
  def mutation(:sleep, start \\ nil, end_ \\ nil) do
    query = """
      mutation ($start: String!, $end: String) {
        sleep(start: $start, end: $end) {
          id
          start
          end
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

    params =
      if start == nil && end_ == nil do
        %{"start" => ""}
      else
        %{
          "start" => TestHelper.format_iso_extended(start),
          "end" => TestHelper.format_iso_extended(end_)
        }
      end

    {query, params}
  end
  def mutation(:sleep_with_comment, start, end_) do
    query = """
      mutation ($start: String!, $end: String!, $comment: Comment) {
        sleep(start: $start, end: $end, comment: $comment) {
          id
          start
          end
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
      "start" => TestHelper.format_iso_extended(start),
      "end" => TestHelper.format_iso_extended(end_),
      "comment" => %{"text" => "Really nice sleep!"}
    }
    {query, params}
  end
end