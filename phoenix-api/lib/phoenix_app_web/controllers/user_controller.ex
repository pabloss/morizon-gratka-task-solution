defmodule PhoenixAppWeb.UserController do
  use PhoenixAppWeb, :controller

  alias PhoenixApp.Accounts
  alias PhoenixApp.Accounts.User

  action_fallback PhoenixAppWeb.FallbackController

  # GET /users (z filtrowaniem)
  def index(conn, params) do
    users = Accounts.list_users(params)
    render(conn, :index, users: users)
  end

  # POST /users
  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  # GET /users/:id
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  # PUT /users/:id
  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  # DELETE /users/:id
  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  # POST /import
  def import_data(conn, _params) do
    # Pobranie tokena z nagłówka
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         true <- valid_token?(token) do

      # Uruchomienie logiki importu
      {:ok, message} = Accounts.import_users_from_source()

      conn
      |> put_status(:accepted)
      |> json(%{status: "ok", message: message})
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or missing API token"})
    end
  end

  # Prosta walidacja - w produkcji trzymaj token w configu/zmiennych środowiskowych
  defp valid_token?("SECRET_API_TOKEN_123"), do: true
  defp valid_token?(_), do: false
end