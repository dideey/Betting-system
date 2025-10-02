defmodule App.AccountsContext do
  import Ecto.Query, warn: false
  alias App.Repo
  alias App.Accounts.User
  alias Bcrypt

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
  def authenticate_user(email, password) do
    case get_user_by_email(email) do
      nil ->
        {:error, :invalid_credentials}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
