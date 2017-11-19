defmodule IclogWeb.ObservationChannelTest do
  use IclogWeb.ChannelCase

  import Iclog.ObservationTestHelper

  alias IclogWeb.ObservationChannel
  alias Iclog.ObservationMetaTestHelper, as: ObmHelper
  alias Iclog.Observable.Observation
  alias Iclog.Observable.ObservationMeta

  setup do
    {query, params} = query(:paginated_observations, 1)

    {:ok, response, socket} =
    socket("user_id", %{some: :assign})
    |> subscribe_and_join(
        ObservationChannel,
        "observation:observation",
        %{"query" => query, "params" => params}
      )

    {:ok, socket: socket, socket_response: response}
  end

  describe "new_observation" do
    test "with_meta replies with status ok, observation and meta", %{socket: socket} do
      {query, params} = mutation(:observation_with_meta)

      ref = push socket, "new_observation", %{
        "with_meta" => "yes",
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{data:  %{"observationWithMeta" => %{"id" => _, "meta" => _}}}
      )
    end

    test "with_meta replies with status error", %{socket: socket} do
      {query, params} = mutation(:observation_with_meta_invalid)

      ref = push socket, "new_observation", %{
        "with_meta" => "yes",
        "query" => query,
        "params" => params
      }

      assert_reply ref, :error, %{errors:  _}
    end

    test "replies with status ok, observation and meta", %{socket: socket} do
      meta = insert :observation_meta
      {query, params} = mutation(:observation, meta.id)

      ref = push socket, "new_observation", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{data:  %{"observation" => %{"id" => _, "meta" => _}}}
      )
    end

    test "replies with status error", %{socket: socket} do
      {query, params} = mutation(:observation, 0)

      ref = push socket, "new_observation", %{
        "query" => query,
        "params" => params
      }

      assert_reply ref, :error, %{errors:  _}
    end
  end

  describe "search_metas_by_title" do
    test "replies with status ok and  metas", %{socket: socket} do
      insert(:observation_meta)

      {query, params} = ObmHelper.valid_query(:observation_metas_by_title_query, "som")

      ref = push socket, "search_metas_by_title", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{data:  %{"observationMetasByTitle" => [%{"id" => _, "title" => _}]}}
      )
    end
  end

  describe "list_observations" do
    test "replies with status ok and list of observations", %{socket: socket} do
      insert_list(11, :observation)

      {query, params} = query(:paginated_observations, 1)

      ref = push socket, "list_observations", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{
          data: %{
            "paginatedObservations" => %{
              "entries" => _,
              "pagination" => %{
                "totalEntries" => 11,
                "pageNumber" => 1,
                "pageSize" => 10,
                "totalPages" => 2,
              }
            }
          }
        }
      )
    end
  end

  describe "get_observation" do
    test "replies with status ok and observation", %{socket: socket} do
      obs = insert(:observation)
      id = Integer.to_string obs.id

      {query, params} = query(:observation, id)

      ref = push socket, "get_observation", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{
          data: %{
            "observation" => %{
              "id" => ^id,
              "meta" => %{
                "id" => _
              }
            }
          }
        }
      )
    end

    test "replies with status error", %{socket: socket} do
      {query, params} = query(:observation, "0")

      ref = push socket, "get_observation", %{
        "query" => query,
        "params" => params
      }

      assert_reply ref, :error, %{errors: _ }
    end
  end

  describe "update_observation" do
    test "replies with status ok and observation", %{socket: socket} do
      %Observation{
        id: id_,
        comment: comment_,
        inserted_at: inserted_at_,
        observation_meta: %ObservationMeta{id: obm_id_}
      } = insert(:observation)

      id = Integer.to_string id_
      obm_id = Integer.to_string obm_id_
      comment = "#{comment_}-updated"

      inserted_at = inserted_at_
      |> Timex.shift(minutes: 5)
      |> Timex.format!("{ISO:Extended:Z}")

      query = mutation :observation_update


      params = %{
        "id" => id,
        "comment" => comment,
        "insertedAt" => inserted_at,
      }

      ref = push socket, "update_observation", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{
          data: %{"observationUpdate" =>
            %{
              "id" =>^id,
              "comment" => ^comment,
              "insertedAt" => ^inserted_at,
              "updatedAt" => _,
              "meta" => %{
                "id" => ^obm_id
              }
            }
          }
        }
      )
    end

    test "replies with status error", %{socket: socket} do
      query = mutation :observation_update

      params = %{
        "id" => "0",
        "comment" => "",
        "insertedAt" => "",
      }

      ref = push socket, "update_observation", %{
        "query" => query,
        "params" => params
      }

      assert_reply ref, :error, %{errors: _}
    end
  end
end
