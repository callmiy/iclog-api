defmodule Iclog.Observable.SleepTest do
    use Iclog.DataCase

    alias Iclog.Observable.Sleep

    @now Timex.now()
    @invalid_attrs %{comment: nil, end: nil, start: nil}


    test "list/0 returns all sleeps" do
      sleep = normalize(insert :sleep)
      assert (Sleep.list() |> List.first() |> normalize()) == sleep
    end

    test "get!/1 returns the sleep with given id" do
      sleep = insert :sleep
      assert normalize(Sleep.get!(sleep.id)) == normalize(sleep)
    end

    test "get/1 returns the sleep with given id and associated comments" do
      %Sleep{comments: [comment]} = sleep = normalize(insert :sleep_with_comment)
      sleep_ = normalize(Sleep.get sleep.id)
      assert sleep_ == %{sleep | comments: [comment]}
    end

    test "get/1 with wrong sleep id returns nil" do
      assert nil == Sleep.get(0)
    end

    test "create/1 with valid data creates a sleep" do
      assert {:ok, %Sleep{} = sleep} = Sleep.create(%{start: @now, end: @now})
      assert sleep.start == @now
      assert sleep.end == @now
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sleep.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the sleep" do
      updated_start = Timex.shift @now, days: 1
      updated_end = Timex.shift @now, days: 1, hours: 5
      sleep_ = insert :sleep, start: @now, end: @now
      sleep = %{sleep_ | comments: []}
      assert {:ok, sleep} = Sleep.update(sleep, %{start: updated_start, end: updated_end})
      assert %Sleep{} = sleep
      assert sleep.start ==  updated_start
      assert sleep.end == updated_end
    end

    test "update/2 with invalid data returns error changeset" do
      sleep = insert :sleep
      assert {:error, %Ecto.Changeset{}} = Sleep.update(sleep, @invalid_attrs)
      assert sleep == Sleep.get!(sleep.id)
    end

    test "delete/1 deletes the sleep" do
      sleep = insert :sleep
      assert {:ok, %Sleep{}} = Sleep.delete(sleep)
      assert_raise Ecto.NoResultsError, fn -> Sleep.get!(sleep.id) end
    end

    test "change/1 returns a sleep changeset" do
      sleep = insert :sleep
      assert %Ecto.Changeset{} = Sleep.change(sleep)
    end

    defp normalize(%Sleep{start: start, end: end_} = sleep) do
      %{sleep | start: normalize_time(start), end: normalize_time(end_)}
    end
end
