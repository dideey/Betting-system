defmodule App.Sports.Game do
  use Ecto.Schema
  import Ecto.Changeset

   @derive {Jason.Encoder, only: [:id, :game_type, :team_a, :team_b, :odds_a, :odds_b, :start_time, :result, :status, :inserted_at, :updated_at]}

  schema "games" do
    field :game_type, :string
    field :team_a, :string
    field :team_b, :string
    field :odds_a, :float
    field :odds_b, :float
    field :start_time, :utc_datetime
    field :result, :string
    field :status, :string, default: "open"

    timestamps(type: :utc_datetime)
  end

  @doc false
def changeset(game, attrs) do
  game
  |> cast(attrs, [:game_type, :team_a, :team_b, :odds_a, :odds_b, :start_time, :result, :status])
  |> validate_required([:game_type, :team_a, :team_b, :odds_a, :odds_b, :start_time, :status])
end

#for resolving a game
def resolve_changeset(game, attrs) do
  game
  |> cast(attrs, [:result, :status])
  |> validate_required([:result])
end


end
