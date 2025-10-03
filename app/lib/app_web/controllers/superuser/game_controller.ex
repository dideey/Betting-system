defmodule AppWeb.Superuser.GameController do
  use AppWeb, :controller
  alias App.SportsContext, as: Games

  # POST /api/superuser/games
  def create(conn, %{"game" => params}) do
    case Games.create_game(params) do
      {:ok, game} ->
        conn
        |> put_status(:created)
        |> json(%{status: "success", message: "Game created", data: game})

      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "Invalid data", errors: errors})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{status: "error", message: "Missing game params"})
  end

  # GET /api/superuser/games
  def index(conn, _params) do
    games = Games.list_games()
    json(conn, %{status: "success", data: games})
  end

  # PUT /api/superuser/games/:id
  def update(conn, %{"id" => id, "game" => params}) do
    case Games.get_game(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Game not found"})

      game ->
        case Games.update_game(game, params) do
          {:ok, updated_game} ->
            json(conn, %{status: "success", message: "Game updated", data: updated_game})

          {:error, changeset} ->
            errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
              Enum.reduce(opts, msg, fn {key, value}, acc ->
                String.replace(acc, "%{#{key}}", to_string(value))
              end)
            end)

            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", message: "Invalid data", errors: errors})
        end
    end
  end

  # DELETE /api/superuser/games/:id
  def delete(conn, %{"id" => id}) do
    case Games.get_game(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Game not found"})

      game ->
        {:ok, _} = Games.delete_game(game)
        json(conn, %{status: "success", message: "Game deleted"})
    end
  end

  # POST /api/superuser/games/:id/resolve
  def resolve(conn, %{"id" => id, "result" => result}) do
    case Games.get_game(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Game not found"})

      game ->
        case Games.set_result(game, result) do
          {:ok, updated_game} ->
            json(conn, %{
              status: "success",
              message: "Game resolved, settlement queued",
              data: %{
                id: updated_game.id,
                result: updated_game.result,
                status: updated_game.status
              }
            })

          {:error, changeset} ->
            errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
              Enum.reduce(opts, msg, fn {key, value}, acc ->
                String.replace(acc, "%{#{key}}", to_string(value))
              end)
            end)

            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", message: "Invalid data", errors: errors})
        end
    end
  end
end
