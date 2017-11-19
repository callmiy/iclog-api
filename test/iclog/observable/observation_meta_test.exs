defmodule Iclog.Observable.ObservationMetaTest do
  use Iclog.DataCase

  alias Iclog.Observable.ObservationMeta

  @valid_attrs %{intro: "some intro", title: "some title"}

  @update_attrs %{intro: "some updated intro", title: "some updated title"}

  @invalid_attrs %{intro: nil, title: nil}

    test "list/0 returns all observation_metas" do
      meta = insert :observation_meta
      assert ObservationMeta.list() == [meta]
    end

    test "get!/1 returns the observation_meta with given id" do
      meta = insert :observation_meta
      assert ObservationMeta.get!(meta.id) == meta
    end

    test "create/1 with valid data creates a observation_meta" do
      assert {:ok, %ObservationMeta{} = meta} = ObservationMeta.create(@valid_attrs)
      assert meta.intro == "some intro"
      assert meta.title == "some title"
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ObservationMeta.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the observation_meta" do
      meta = insert :observation_meta
      assert {:ok, meta} = ObservationMeta.update(meta, @update_attrs)
      assert %ObservationMeta{} = meta
      assert meta.intro == "some updated intro"
      assert meta.title == "some updated title"
    end

    test "update/2 with invalid data returns error changeset" do
      meta = insert :observation_meta
      assert {:error, %Ecto.Changeset{}} = ObservationMeta.update(meta, @invalid_attrs)
      assert meta == ObservationMeta.get!(meta.id)
    end

    test "delete/1 deletes the observation_meta" do
      meta = insert :observation_meta
      assert {:ok, %ObservationMeta{}} = ObservationMeta.delete(meta)
      assert_raise Ecto.NoResultsError, fn -> ObservationMeta.get!(meta.id) end
    end

    test "change/1 returns a observation_meta changeset" do
      meta = insert :observation_meta
      assert %Ecto.Changeset{} = ObservationMeta.change(meta)
    end
end
