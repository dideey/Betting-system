defmodule App.SportsContext do
  import Ecto.Query, warn: false
  alias App.Repo
  alias App.Sports.Game

  #get a game by id
  def get_game!(id), do: Repo.get!(Game, id)

  def get_game(id), do: Repo.get(Game, id)


  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |>
     Repo.update()
  end

  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  #superuser creates games
  def create_game(attrs) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()

  end
  #list all of te games
  def list_games do
    Repo.all(Game)
  end

  # Called by superuser to set final result (will enqueue settlement)
  def set_result(%Game{} = game, result) do
  changeset = Game.resolve_changeset(game, %{result: result, status: "closed"})
  updated_game = Repo.update!(changeset)

  App.BetSettlementQueue.enqueue({:settle_game, updated_game.id})
  {:ok, updated_game}
end


end
