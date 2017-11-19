defmodule Iclog.Observable.ObservationTest do
  use Iclog.DataCase

  alias Iclog.Observable.Observation
  alias Iclog.Observable.ObservationMeta

  describe "observation" do
    test "list/0 returns all observations" do
      %ObservationMeta{id: meta_id} = insert :observation_meta
      observation_ = build :observation_no_meta
      %Observation{id: id} = Repo.insert! Map.put(observation_, :observation_meta_id, meta_id)
      assert [%Observation{id: ^id}] = Observation.list()
    end

    test "list/1 returns all observations with meta preloaded" do
      %Observation{
        id: id, observation_meta: %ObservationMeta{id: meta_id}
      } = insert :observation

      assert [%Observation{
        id: ^id,
        observation_meta: %ObservationMeta{id: ^meta_id}
      }] = Observation.list(:with_meta)
    end

    test "get!/1 returns the observation with given id" do
      %Observation{id: id} = insert :observation
      assert %Observation{id: ^id} = Observation.get!(id)
    end

    test "create/1 with valid data creates a observation" do
      %ObservationMeta{id: meta_id} = insert :observation_meta
      assert {:ok, %Observation{} = observation} =
        Observation.create(%{comment: "some comment", observation_meta_id: meta_id})
      assert observation.comment == "some comment"
    end

    test "create/2 with valid data creates a observation" do
      assert {:ok, %{id: _, meta: %{id: _}}} =
        Observation.create(
          %{comment: "some comment"},
          %{title: "some title"}
        )
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Observation.create(%{})
    end

    test "update/2 with valid data updates the observation" do
      observation = insert :observation
      assert {:ok, observation} = Observation.update(observation, %{comment: "some updated comment"})
      assert %Observation{} = observation
      assert observation.comment == "some updated comment"
    end

    test "delete/1 deletes the observation" do
      observation = insert :observation
      assert {:ok, %Observation{}} = Observation.delete(observation)
      assert_raise Ecto.NoResultsError, fn -> Observation.get!(observation.id) end
    end

    test "change/1 returns a observation changeset" do
      observation = insert :observation
      assert %Ecto.Changeset{} = Observation.change(observation)
    end
  end
end
