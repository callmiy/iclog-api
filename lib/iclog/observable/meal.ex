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

  """
  def list do
    Repo.all(Meal)
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

  @doc """
  Creates a meal.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Meal{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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
    meal
    |> Meal.changeset(attrs)
    |> Repo.update()
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
end
