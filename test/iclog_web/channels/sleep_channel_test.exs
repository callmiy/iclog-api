defmodule IclogWeb.SleepChannelTest do
  use IclogWeb.ChannelCase

  import Iclog.SleepTestHelper

  alias IclogWeb.SleepChannel
  alias Iclog.Observable.Sleep

  @start Timex.now()
  @end_ Timex.shift(Timex.now(), hours: 5)

  def init(_) do
    {query, params} = query(:paginated_sleeps, 1)

    {:ok, response, socket} =
    socket("user_id", %{some: :assign})
    |> subscribe_and_join(
        SleepChannel,
        "sleep:sleep",
        %{"query" => query, "params" => params}
      )

    {:ok, socket: socket, socket_response: response}
  end

  def init_with_sleeps(_) do
    insert_list(11, :sleep)
    {:ok, created: true}
  end

  describe "socket response" do
    setup [:init_with_sleeps, :init]

    test "successful response", %{socket_response: socket_response} do
      assert %{
        data: %{
          "paginatedSleeps" => %{
            "entries" => _,
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

  describe "new_sleep" do
    setup :init

    test "replies with status ok and created sleep, and broadcasts sleep",
        %{socket: socket} do
      {query, params} = mutation(:sleep, @start, @end_)

      ref = push socket, "new_sleep", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{"id" => _}
      )

      assert_push(
        "sleep_created",
        %{data:  %{"sleep" => %{"id" => _, "comments" => _}}}
      )
    end

    test "replies with status error", %{socket: socket} do
      {query, params} = mutation(:sleep)

      ref = push socket, "new_sleep", %{
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

  describe "list_sleeps" do
    setup :init

    test "replies with status ok and sleeps", %{socket: socket} do
      insert(:sleep)
      {query, params} = query(:paginated_sleeps, 1)

      ref = push socket, "list_sleeps", %{
        "query" => query,
        "params" => params
      }

      assert_reply ref, :ok, %{data: %{"paginatedSleeps" => %{"entries" => _}}}
    end
  end

  describe "get_sleep" do
    setup :init

    test "replies with status ok and sleep", %{socket: socket} do
      sleep = insert(:sleep)
      {query, params} = query(:sleep, sleep.id)

      ref = push socket, "get_sleep", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{data:  %{"sleep" => %{"id" => _, "comments" => _}}}
      )
    end

    test "replies with status error", %{socket: socket} do
      {query, params} = query(:sleep, 0)

      ref = push socket, "new_sleep", %{
        "query" => query,
        "params" => params
      }

      assert_reply ref, :error, %{errors: _}
    end
  end

  describe "update_sleep" do
    setup :init

    test "replies with status ok and updated sleep, and broadcasts sleep",
        %{socket: socket} do

      %Sleep{
        id: id_
      } = insert(:sleep)

      query = mutation(:sleep_update)

      id = "#{id_}"
      start = format_iso_extended (Timex.shift @start, days: 5)
      end_ = format_iso_extended (Timex.shift @end_, days: 5)

      params = %{
        "id" => id,
        "start" => start,
        "end" => end_,
      }

      ref = push socket, "update_sleep", %{
        "query" => query,
        "params" => params
      }

      assert_reply(
        ref,
        :ok,
        %{data:  %{"sleepUpdate" => %{"id" => _, "comments" => _}}}
      )

      assert_push(
        "sleep_updated",
        %{"id" => _id, "end" => _, "start" => _}
      )
    end

    test "replies with status error", %{socket: socket} do
      query = mutation(:sleep_update)
      params = %{
        "id" => "0",
        "start" => "",
        "end" => "",
      }

      ref = push socket, "update_sleep", %{
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