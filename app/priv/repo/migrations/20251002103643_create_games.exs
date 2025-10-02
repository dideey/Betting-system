defmodule App.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :game_type, :string
      add :team_a, :string
      add :team_b, :string
      add :odds_a, :float
      add :odds_b, :float
      add :start_time, :utc_datetime
      add :result, :string

      timestamps(type: :utc_datetime)
    end
  end
end
