defmodule App.Sports.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :game_type, :string
    field :team_a, :string
    field :team_b, :string
    field :odds_a, :float
    field :odds_b, :float
    field :start_time, :utc_datetime
    field :result, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:game_type, :team_a, :team_b, :odds_a, :odds_b, :start_time, :result])
    |> validate_required([:game_type, :team_a, :team_b, :odds_a, :odds_b, :start_time, :result])
  end
end
