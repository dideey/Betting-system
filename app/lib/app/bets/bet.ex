defmodule App.Bets.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :user_id, :game_id, :chosen_team, :bet_amount, :odds_at_time, :status, :payout]}

  schema "bets" do
    field :chosen_team, :string
    field :bet_amount, :integer
    field :odds_at_time, :float
    field :status, :string, default: "open"
    field :payout, :integer

    belongs_to :user, App.Accounts.User, foreign_key: :user_id
    belongs_to :game, App.Sports.Game, foreign_key: :game_id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bet, attrs) do
    bet
    |> cast(attrs, [:chosen_team, :bet_amount, :odds_at_time, :status, :payout, :user_id, :game_id])
    |> validate_required([:chosen_team, :bet_amount, :odds_at_time, :status, :payout, :user_id, :game_id])
  end
end
