defmodule App.Bets.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bets" do
    field :chosen_team, :string
    field :bet_amount, :integer
    field :odds_at_time, :float
    field :status, :string
    field :payout, :integer
    field :user_id, :id
    field :game_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bet, attrs) do
    bet
    |> cast(attrs, [:chosen_team, :bet_amount, :odds_at_time, :status, :payout])
    |> validate_required([:chosen_team, :bet_amount, :odds_at_time, :status, :payout])
  end
end
