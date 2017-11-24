defmodule Iclog.Observable.Sleep do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Iclog.Repo
  alias Iclog.Observable.Sleep
  alias Iclog.Comment
  alias IclogWeb.PaginationHelper

  @timestamps_opts [
    type: Timex.Ecto.DateTime,
    autogenerate: {Timex.Ecto.DateTime, :autogenerate, []}
  ]

  schema "sleeps" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    has_many :comments, {"sleep_comments", Comment}, foreign_key: :comment_id

    timestamps()
  end

  @doc false
  def changeset(%Sleep{} = sleep, attrs) do
    sleep
    |> cast(attrs, [:start, :end])
    |> validate_required([:start, :end])
  end

  @doc """
  Returns the list of sleeps.

  ## Examples

      iex> list()
      [%Sleep{}, ...]

  """
  def list do
    Repo.all(Sleep)
  end

  def list_all(params \\ nil) do
    query = from s in Sleep,
      order_by: [desc: s.start, desc: s.id],
      preload: [:comments]

    if params == nil do
      Repo.all query
    else
      page = Repo.paginate(query, params)
      %{
        entries: page.entries,
        pagination: PaginationHelper.page_to_map(page)
      }
    end
  end

  @doc """
  Gets a single sleep.

  Raises `Ecto.NoResultsError` if the Sleep does not exist.

  ## Examples

      iex> get!(123)
      %Sleep{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Sleep, id)
  def get(id) do
    case Repo.get(Sleep, id) do
      nil ->
        nil
      sleep ->
        Repo.preload sleep, [:comments]
    end
  end

  @doc """
  Creates a sleep.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Sleep{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(%{comment: _} = attrs) do
    {comment_, attrs_} = Map.pop attrs, :comment

    if comment_ == nil do
      create(attrs_)
    else
      with {:ok, sleep} <- create(attrs_),
           {:ok, comment} <- create_comment(sleep, comment_) do
        {:ok, %{sleep | comments: [comment]}}
      end
    end
  end
  def create(%{end: _} = attrs) do
    changes = Sleep.changeset(%Sleep{}, attrs)

    with {:ok, sleep} <- Repo.insert(changes) do
      {:ok, Repo.preload(sleep, [:comments])}
    end
  end
  def create(%{start: start} = attrs) do
    create(Map.put attrs, :end, start)
  end

  @doc """
  Updates a sleep.

  ## Examples

      iex> update(sleep, %{field: new_value})
      {:ok, %Sleep{}}

      iex> update(sleep, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Sleep{} = sleep, %{comment: _} = attrs) do
    {comment_, attrs_} = Map.pop attrs, :comment

    if comment_ == nil do
      Sleep.update(sleep, attrs_)
    else
      with {:ok, %Sleep{comments: comments} = sleep_} <- Sleep.update(sleep, attrs_),
           {:ok, comment} <- create_comment(sleep_, comment_) do
        {:ok, %{sleep_ | comments: [comment | comments] } }
      end
    end
  end
  def update(%Sleep{} = sleep, attrs) do
    chgset = Sleep.changeset(sleep, attrs)

    with {:ok, sleep_} <- Repo.update(chgset) do
      {:ok, Repo.preload(sleep_, [:comments])}
    end
  end

  @doc """
  Deletes a Sleep.

  ## Examples

      iex> delete(sleep)
      {:ok, %Sleep{}}

      iex> delete(sleep)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Sleep{} = sleep) do
    Repo.delete(sleep)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sleep changes.

  ## Examples

      iex> change(sleep)
      %Ecto.Changeset{source: %Sleep{}}

  """
  def change(%Sleep{} = sleep) do
    changeset(sleep, %{})
  end

  def create_comment(%Sleep{} = sleep, attrs) do
    Repo.insert(Ecto.build_assoc sleep, :comments, attrs)
  end
end
