defmodule App.AccountsContext do
  import Ecto.Query, warn: false
  alias App.Repo
  alias App.Accounts.User
  alias Bcrypt

  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)



  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def register_user(attrs \\ %{}) do
  %User{}
  |> User.registration_changeset(attrs)
  |> Repo.insert()
end

  def authenticate_user(email, password) do
    case get_user_by_email(email) do
      nil ->
        {:error, :invalid_credentials}

      %User{is_active: false} ->
        {:error, :account_inactive}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, Repo.get(User, user.id)}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def get_user_with_bets(id) do
    Repo.get(User, id)
    |> Repo.preload(bets: [:game])
  end

  def list_users do
    User
    |> where([u], is_nil(u.deleted_at))
    |> Repo.all()
  end

  def update_user_role(%User{} = user, %{"user_type" => new_role}) do
    user
    |> User.role_changeset(%{user_type: new_role})
    |> Repo.update()
  end

  def soft_delete_user(%User{} = user) do
    user
    |> User.deactivate_changeset()
    |> Repo.update()
  end
end
