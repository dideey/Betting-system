defmodule App.Accounts do
  import Ecto.Query, warn false
  alias App.Repo
  alias App.Sports.Game

  #supersuer creates games
  def create_game(attrs) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()

  end
  #list all of te games
  def list_games do
    Repo.all(Game)
  end
end
