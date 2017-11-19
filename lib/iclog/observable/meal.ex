defmodule Iclog.Observable.Meal do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Iclog.Repo
  alias Iclog.Observable.Meal
  alias Iclog.Comment

  @timestamps_opts [
    type: Timex.Ecto.DateTime,
    autogenerate: {Timex.Ecto.DateTime, :autogenerate, []}
  ]

  schema "meals" do
    field :meal, :string
    field :time, Timex.Ecto.DateTime
    has_many :comments, {"meal_comments", Comment}, foreign_key: :comment_id

    timestamps()
  end

  @doc false
  def changeset(%Meal{} = meal, attrs) do
    meal
    |> cast(attrs, [:meal, :time])
    |> validate_required([:meal, :time])
  end

  @doc """
  Returns the list of meals.

  ## Examples

      iex> list()
      [%Meal{}, ...]

      iex> list_all()
      [%Meal{comments: %Comment{}}, ...]

  """
  def list do
    Repo.all(Meal)
  end
  def list_all do
    Enum.uniq(
      Repo.all from m in Meal,
      join: c in assoc(m, :comments),
      preload: [:comments]
    )
  end

  @doc """
  Gets a single meal.

  Raises `Ecto.NoResultsError` if the Meal does not exist.

  ## Examples

      iex> get!(123)
      %Meal{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Meal, id)
  def get(id) do
    case Repo.get(Meal, id) do
      nil ->
        nil
      meal ->
        comments = Repo.all Ecto.assoc(meal, :comments)
        %{meal | comments: comments}
    end
  end

  @doc """
  Creates a meal.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Meal{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(%{comment: nil} = attrs) do
    {_, attrs_} = Map.pop attrs, :comment
    create(attrs_)
  end
  def create(%{comment: %{text: _}} = attrs) do
    {comment_, attrs_} = Map.pop attrs, :comment
    with {:ok, meal} <- create(attrs_),
         {:ok, comment} <- Repo.insert(Ecto.build_assoc meal, :comments, comment_) do
     {:ok, %{meal | comments: [comment]}}
    end
  end
  def create(attrs \\ %{}) do
    %Meal{}
    |> Meal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a meal.

  ## Examples

      iex> update(meal, %{field: new_value})
      {:ok, %Meal{}}

      iex> update(meal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Meal{} = meal, attrs) do
    chgset = Meal.changeset(meal, attrs)
    with {:ok, meal_} <- Repo.update(chgset) do
      comments = Repo.all Ecto.assoc(meal_, :comments)
      {:ok, %{meal_ | comments: comments}}
    end
  end

  @doc """
  Deletes a Meal.

  ## Examples

      iex> delete(meal)
      {:ok, %Meal{}}

      iex> delete(meal)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Meal{} = meal) do
    Repo.delete(meal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meal changes.

  ## Examples

      iex> change(meal)
      %Ecto.Changeset{source: %Meal{}}

  """
  def change(%Meal{} = meal) do
    Meal.changeset(meal, %{})
  end

   @doc """
  Creates comment for a meal.

  ## Examples

      iex> create_comment(meal, %{text: value})
      {:ok, %Meal{comments: []}}

      iex> create_comment(meal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(%Meal{} = meal, %{text: _} = attrs) do
    Repo.insert(Ecto.build_assoc meal, :comments, attrs)
  end
end
