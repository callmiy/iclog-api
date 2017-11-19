defmodule Iclog.ObservationTestHelper do

  def query(:observations) do
    """
    {
      observations {
        id
        comment
        insertedAt
        updatedAt
        meta {
          id
          title
          intro
        }
      }
    }
    """
  end
  def query(:paginated_observations, page_number) do
    query = """
      query ($pagination: PaginationParams!) {
        paginatedObservations(
          pagination: $pagination
        ) {
            entries {
              id
              comment
              insertedAt
              updatedAt
              meta {
                id
                title
                intro
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
  def query(:observation, id) do
    query = """
      query ($id: ID!) {
        observation(id: $id) {
          id
          comment
          insertedAt
          updatedAt
          meta {
            id
            title
            intro
          }
        }
      }
    """

    params = %{"id" => id}
    {query, params}
  end

  def mutation(:observation_with_meta) do
    query = """
      mutation ($comment: String!, $meta: Meta!) {
        observationWithMeta(
          comment: $comment,
          meta: $meta
        ) {
          id
          meta {
            id
          }
        }
      }
    """

    params = %{
      "comment" => "some comment",
      "meta" => %{"title" => "nice title"}
    }

    {query, params}
  end
  def mutation(:observation_with_meta_invalid) do
    query = """
      mutation ($comment: String!, $meta: Meta!) {
        observationWithMeta(
          comment: $comment,
          meta: $meta
        ) {
          id
          meta {
            id
          }
        }
      }
    """

    params = %{
      "comment" => "some comment"
    }

    {query, params}
  end
  def mutation(:observation_update) do
    """
      mutation ($id: ID!, $comment: String, $insertedAt: String) {
        observationUpdate(
          id: $id
          comment: $comment
          insertedAt: $insertedAt
        ) {
          id
          comment
          insertedAt
          updatedAt
          meta {
            id
            title
            intro
          }
        }
      }
    """
  end
  def mutation(:observation, observation_meta_id) do
    query = """
      mutation ($comment: String!, $metaId: ID!) {
        observation(
          comment: $comment,
          metaId: $metaId
        ) {
          id
          comment
          insertedAt
          updatedAt
          meta {
            id
            title
            intro
          }
        }
      }
    """

    params = %{
      "comment" => "some comment",
      "metaId" => "#{observation_meta_id}"
    }

    {query, params}
  end
end