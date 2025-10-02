defmodule App.Repo.Migrations.CreateUserz do
  use Ecto.Migration

  def change do
    create table(:userz) do
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :password_hash, :string
      add :user_type, :string
      add :is_active, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:userz, [:email])
  end
end
