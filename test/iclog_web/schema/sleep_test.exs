defmodule IclogWeb.Schema.SleepTest do
  use Iclog.DataCase
  import Iclog.SleepTestHelper

  alias Iclog.Observable.Sleep
  alias Iclog.Comment
  alias IclogWeb.Schema

  @start Timex.now()
  @end_ Timex.shift(Timex.now(), hours: 5)

  describe "query" do
    test "sleep returns sleep" do
      %Sleep{
        id: id_,
        start: _start_,
        end: _end_,
        comments: [%Comment{
          id: comment_id_,
          text: text
        }]
      }  = insert(:sleep_with_comment)

      id = Integer.to_string id_
      comment_id = Integer.to_string comment_id_
      {query, params} = query(:sleep, id)

      assert {:ok, %{
        data: %{
          "sleep" => %{
            "id" => ^id,
            "start" => _,
            "end" => _,
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

    test "sleep returns error" do
      {query, params} = query(:sleep, 0)

      assert {:ok, %{
          errors: [%{message: _}]
        }
      } = Absinthe.run(query, Schema, variables: params)
    end

    test "sleeps" do
      %Sleep{
        id: id_,
      } = sleep_ = insert(:sleep)

      SleepCommentFactory.create_list 3, :comment, sleep: sleep_
      id = Integer.to_string id_

      assert {:ok, %{
          data: %{
            "sleeps" => [%{
              "id" => ^id,
              "start" => _,
              "end" => _,
              "insertedAt" => _,
              "updatedAt" => _,
              "comments" => comments
            }]
          }
        }
      } = Absinthe.run(query(:sleeps), Schema)

      assert length(comments) == 3
    end

    test ":paginated_sleeps page number 1 succeeds" do
      insert_list(11, :sleep)
      {query, params} = query(:paginated_sleeps, 1)

      {:ok, %{
          data: %{
            "paginatedSleeps" => %{
              "entries" => sleeps,
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

      assert length(sleeps) == 10

      assert %{
        "id" => _,
        "start" => _,
        "end" => _,
        "insertedAt" => _,
        "updatedAt" => _,
        "comments" => []
      } = List.first(sleeps)
    end

    test ":paginated_sleeps page number 2 succeeds" do
      insert_list(11, :sleep_with_comment)

      {query, params} = query(:paginated_sleeps, 2)

      {:ok, %{
          data: %{
            "paginatedSleeps" => %{
              "entries" => sleeps,
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
        "start" => _,
        "end" => _,
        "insertedAt" => _,
        "updatedAt" => _,
        "comments" => [%{
          "id" => _,
          "text" => _,
          "insertedAt" => _,
        }]
      }] = sleeps
    end
  end

  describe "mutation" do
    test ":sleep succeeds" do
      {query, params} = mutation(:sleep, @start, @end_)

      assert {:ok, %{data: %{"sleep" => %{"id" => _, "comments" => []} } }} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":sleep fails" do
      {query, params} = mutation(:sleep)

      assert {:ok, %{errors: _}} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":sleep with comment succeeds" do
      {query, params} = mutation(:sleep_with_comment, @start, @end_)

      assert {
        :ok, %{
          data: %{
            "sleep" => %{
              "id" => _,
              "comments" => [%{
                "text" => text,
              }]
            }
          }
        }
      } = Absinthe.run(query, Schema, variables: params)

      assert text == "Really nice sleep!"
    end

    test ":sleep_comment succeeds" do
      %Sleep{id: id} = insert :sleep
      {query, params} = mutation(:sleep_comment, id)

      assert {:ok, %{data: %{"sleepComment" => %{"id" => _, "text" => _} } }} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":sleep_comment errors" do
      {query, params} = mutation(:sleep_comment, 0)

      assert {:ok, %{errors: _}} =
        Absinthe.run(query, Schema, variables: params)
    end

    test ":sleep_update succeeds" do
      %Sleep{
        id: id_,
        comments: [%Comment{
          id: comment_id_,
          text: text
        }]
      } = insert(:sleep_with_comment, start: @start, end: @end_)

      id = "#{id_}"
      comment_id = "#{comment_id_}"
      start = format_iso_extended (Timex.shift @start, days: 5)
      end_ = format_iso_extended (Timex.shift @end_, days: 5)

      params = %{
        "id" => id,
        "start" => start,
        "end" => end_,
      }

      assert {:ok,
            %{data:
              %{"sleepUpdate" =>
                %{
                    "id" =>^id,
                    "start" => ^start,
                    "end" => ^end_,
                    "insertedAt" => _,
                    "updatedAt" => _,
                    "comments" => [%{
                      "id" => ^comment_id,
                      "text" => ^text,
                    }]
                }
              }
            }
        } =
      Absinthe.run(mutation(:sleep_update), Schema, variables: params)
    end

    test ":sleep_update errors" do
      params = %{
        "id" => "0",
        "start" => "",
        "end" => "",
      }

      assert {:ok, %{errors: _}} =
        Absinthe.run(mutation(:sleep_update), Schema, variables: params)
    end

    test ":sleep_update with comment succeeds" do
      %Sleep{
        id: id_,
      } = insert(:sleep_with_comment, start: @start)

      id = Integer.to_string id_
      start = format_iso_extended (Timex.shift @start, days: 5)

      params = %{
        "id" => id,
        "start" => start,
        "comment" => %{
          "text" => "This is another comment"
        }
      }

      assert {:ok,
            %{data:
              %{"sleepUpdate" =>
                %{
                    "id" =>^id,
                    "start" => ^start,
                    "end" => _,
                    "insertedAt" => _,
                    "updatedAt" => _,
                    "comments" => comments
                }
              }
            }
        } =
      Absinthe.run(mutation(:sleep_update_with_comment), Schema, variables: params)

      assert length(comments) == 2
      assert %{"text" => "This is another comment"} = List.first(comments)
    end
  end
end