defmodule AppWeb.AuthController do
  use AppWeb, :controller
  alias  App.AccountsContext

  # Show login form
  def new(conn, _params) do
    render(conn, :new)
  end

  # Show registration form
  def register(conn, _params) do
    render(conn, :register)
  end

  # Handle login form submission
  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case AccountsContext.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Login successful")
        |> redirect(to: ~p"/")
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> render(:new)
    end
  end

  # Handle registration form submission
  def create(conn, %{"user" => user_params}) do
    case AccountsContext.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Registration successful")
        |> redirect(to: ~p"/")
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Registration failed")
        |> render(:register, changeset: changeset)
    end
  end

  # Handle logout
  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logged out successfully")
    |> redirect(to: ~p"/")
  end

  #lets admin soft deactivate users accounts
  def deactivate(conn, %{user_id}) do

  end
end
