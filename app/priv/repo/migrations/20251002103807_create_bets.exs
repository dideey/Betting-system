defmodule App.Repo.Migrations.CreateBets do
  use Ecto.Migration

  def change do
    create table(:bets) do
      add :chosen_team, :string
      add :bet_amount, :integer
      add :odds_at_time, :float
      add :status, :string
      add :payout, :integer
      add :user_id, references(:userz, on_delete: :nothing)
      add :game_id, references(:games, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:bets, [:user_id])
    create index(:bets, [:game_id])
  end
end
