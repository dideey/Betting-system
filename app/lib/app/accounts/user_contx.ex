defmodule App.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  # JSON encoding for User struct
  @derive {Jason.Encoder, only: [:id, :first_name, :last_name, :email, :user_type, :is_active, :inserted_at, :updated_at]}

  schema "userz" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :user_type, :string, default: "user"
    field :is_active, :boolean, default: true
    has_many :bets, App.Bets.Bet, foreign_key: :user_id


    timestamps(type: :utc_datetime)
  end

  @doc false
 def registration_changeset(user, attrs) do
  user
  |> cast(attrs, [:first_name, :last_name, :email, :password])
  |> validate_required([:first_name, :last_name, :email, :password])
  |> validate_length(:password, min: 6)
  |> validate_format(:email, ~r/@/)
  |> unique_constraint(:email)
  |> hash_password()
  |> put_change(:is_active, true)   # default only for new users
  |> put_change(:user_type, "user")
end

def changeset(user, attrs) do
  user
  |> cast(attrs, [:first_name, :last_name, :email, :password, :is_active, :user_type])
  |> validate_format(:email, ~r/@/)
  |> validate_length(:password, min: 6)
  |> hash_password()
end

#Changeset for updating a user's role (user_type).
def role_changeset(user, attrs) do
  user
  |> cast(attrs, [:user_type])
  |> validate_required([:user_type])
  |> validate_inclusion(:user_type, ["user", "admin", "superuser"])
end

  # Changeset for deactivating a user
  def deactivate_changeset(user) do
    change(user, is_active: false)
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset
end
