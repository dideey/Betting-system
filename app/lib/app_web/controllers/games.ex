defmodule AppWeb.GameController do
  use AppWeb, :controller
  alias App.GameContext

  def new_game(conn, _params) do
    render(conn, :new_game)
  end

  #creates new games
  def create(conn, %{"game" => game_params}) do
    case GameContext.create_game(game_params) do
      {:ok, game} ->
        conn
        |> put_flash(:info, "Game created successfully")
        |> redirect(to: ~p"/games/#{game.id}")
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Game creation failed")
        |> render(:new_game, changeset: changeset)
    end

  end
end
