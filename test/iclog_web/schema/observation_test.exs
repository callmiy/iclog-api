defmodule IclogWeb.Schema.ObservationTest do
  use Iclog.DataCase
  import Iclog.ObservationTestHelper

  alias Iclog.Observable.Observation
  alias Iclog.Observable.ObservationMeta
  alias IclogWeb.Schema

  describe "query" do
    test "observation_query returns ok" do
      %Observation{
        id: id_,
        comment: comment,
        observation_meta: %ObservationMeta{
          id: obm_id_,
          title: title,
          intro: intro,
        }
      } = insert(:observation)

      id = Integer.to_string id_
      obm_id = Integer.to_string obm_id_

      {query, params} = query(:observation, id)

      assert {:ok, %{
          data: %{
            "observation" => %{
              "id" => ^id,
              "comment" => ^comment,
              "insertedAt" => _,
              "updatedAt" => _,
              "meta" => %{
                "id" => ^obm_id,
                "title" => ^title,
                "intro" => ^intro,
              }
            }
          }
        }
      } = Absinthe.run(query, Schema, variables: params)
    end

    test "observation_query returns error" do
      {query, params} = query(:observation, "0")

      assert {:ok, %{
          errors: [%{message: _}]
        }
      } = Absinthe.run(query, Schema, variables: params)
    end

    test "observations_query" do
      %Observation{
        id: id_,
        comment: comment,
        observation_meta: %ObservationMeta{
          id: obm_id_,
          title: title,
          intro: intro,
        }
      } = insert(:observation)

      id = Integer.to_string id_
      obm_id = Integer.to_string obm_id_

      assert {:ok, %{
          data: %{
            "observations" => [%{
              "id" => ^id,
              "comment" => ^comment,
              "insertedAt" => _,
              "updatedAt" => _,
              "meta" => %{
                "id" => ^obm_id,
                "title" => ^title,
                "intro" => ^intro,
              }
            }]
          }
        }
      } = Absinthe.run(query(:observations), Schema)
    end

    test ":paginated_observations_query page number 1 succeeds" do
      insert_list(11, :observation)

      {query, params} = query(:paginated_observations, 1)

      {:ok, %{
          data: %{
            "paginatedObservations" => %{
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
        "comment" => _,
        "insertedAt" => _,
        "updatedAt" => _,
        "meta" => %{
          "id" => _,
          "title" => _,
          "intro" => _,
        }
      } = List.first(obs)
    end

    test ":paginated_observations_query page number 2 succeeds" do
      insert_list(11, :observation)

      {query, params} = query(:paginated_observations, 2)

      {:ok, %{
          data: %{
            "paginatedObservations" => %{
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
        "comment" => _,
        "insertedAt" => _,
        "updatedAt" => _,
        "meta" => %{
          "id" => _,
          "title" => _,
          "intro" => _,
        }
      }] = obs
    end
  end

  describe "mutation" do
    test ":observation_with_meta succeeds" do
      {query, params} = mutation(:observation_with_meta)

      assert {:ok, %{data: %{"observationWithMeta" => %{"id" => _} } }} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":observation_with_meta errors" do
      {query, params} = mutation(:observation_with_meta_invalid)

      assert {:ok, %{errors: _}} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":observation succeeds" do
      %ObservationMeta{id: id} = insert :observation_meta
      obm_id = Integer.to_string id
      {query, params} = mutation(:observation, id)

      assert {:ok,
                %{data:
                  %{"observation" =>
                    %{
                        "id" => _,
                        "meta" => %{
                          "id" => ^obm_id
                        }
                    }
                  }
                }
            } =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":observation errors" do
      {query, params} = mutation(:observation, 0)

      assert {:ok, %{errors: _}} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":observation_update succeeds" do
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

      inserted_at_str = Timex.format!(inserted_at, "{ISO:Extended:Z}")
      query = mutation :observation_update
      params = %{
        "id" => id,
        "comment" => comment,
        "insertedAt" => inserted_at_str,
      }

      assert {:ok,
            %{data:
              %{"observationUpdate" =>
                %{
                    "id" =>^id,
                    "comment" => ^comment,
                    "insertedAt" => ^inserted_at_str,
                    "updatedAt" => _,
                    "meta" => %{
                      "id" => ^obm_id
                    }
                }
              }
            }
        } =
      Absinthe.run(query, Schema, variables: params)
    end

    test ":observation_update errors" do
      query = mutation :observation_update

      params = %{
        "id" => "0",
        "comment" => "",
        "insertedAt" => "",
      }

      assert {:ok, %{errors: _}} =
        Absinthe.run(query, Schema, variables: params)
    end
  end
end
