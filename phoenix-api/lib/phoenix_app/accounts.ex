defmodule PhoenixApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias PhoenixApp.Repo

  alias PhoenixApp.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """

  # Główna funkcja pobierająca z opcjonalnymi filtrami
  def list_users(params \\ %{}) do
    User
    |> filter_by_name(params)
    |> filter_by_gender(params)
    |> filter_by_birthdate(params)
    |> sort_users(params)
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  # --- Filtry (Pattern Matching) ---

  # ilike w Postgres = case insensitive search
  defp filter_by_name(query, %{"first_name" => name}) when is_binary(name) do
    where(query, [u], ilike(u.first_name, ^"%#{name}%"))
  end
  defp filter_by_name(query, %{"last_name" => name}) when is_binary(name) do
    where(query, [u], ilike(u.last_name, ^"%#{name}%"))
  end
  defp filter_by_name(query, _), do: query

  defp filter_by_gender(query, %{"gender" => gender}) when gender in ["male", "female"] do
    where(query, [u], u.gender == ^gender)
  end
  defp filter_by_gender(query, _), do: query

  defp filter_by_birthdate(query, %{"birthdate_from" => date}) do
    where(query, [u], u.birthdate >= ^Date.from_iso8601!(date))
  rescue ArgumentError -> query # Ignorujemy błędny format daty
  end

  defp filter_by_birthdate(query, %{"birthdate_to" => date}) do
    # Można tu łączyć zapytania (query composition)
    where(query, [u], u.birthdate <= ^Date.from_iso8601!(date))
  rescue ArgumentError -> query
  end
  defp filter_by_birthdate(query, _), do: query

  # --- Sortowanie ---

  defp sort_users(query, %{"sort_by" => field, "order" => order})
       when field in ["first_name", "last_name", "birthdate", "gender"] and order in ["asc", "desc"] do
    order_by(query, [u], [{^String.to_existing_atom(order), field(u, ^String.to_existing_atom(field))}])
  end
  # Domyślne sortowanie
  defp sort_users(query, _), do: order_by(query, [u], asc: u.id)


  # Funkcja pomocnicza do importu
  def import_users_from_source do
    # Tu byłaby logika parsowania CSV/JSON i wstawiania do bazy
    # Np. Repo.insert_all albo Multi.new
    {:ok, "Import started in background"}
  end
end
