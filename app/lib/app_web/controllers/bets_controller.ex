defmodule AppWeb.BetController do
  use AppWeb, :controller

  alias App.Bets
  alias App.Accounts.User
  alias App.Bets.Bet

  plug :authenticate_user

  # List all bets for current user
  def index(conn, _params) do
    user = conn.assigns.current_user
    bets = Bets.list_bets_by_user(user.id)

    conn
    |> put_status(:ok)
    |> json(%{
      status: "success",
      data: Enum.map(bets, &serialize_bet/1)
    })
  end

  # Place a new bet
  def create(conn, %{"game_id" => game_id, "stake" => stake, "selection" => selection}) do
    user = conn.assigns.current_user

    case Bets.place_bet(user, %{"game_id" => game_id, "stake" => stake, "selection" => selection}) do
      {:ok, bet} ->
        conn
        |> put_status(:created)
        |> json(%{
          status: "success",
          message: "Bet placed successfully",
          data: serialize_bet(bet)
        })

      {:error, :game_closed} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "Cannot bet: game is closed"})

      {:error, :invalid_selection} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "Invalid selection"})

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "Invalid data", errors: errors})
    end
  end

  # Cancel an existing bet
  def cancel(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    case Bets.cancel_bet(user, String.to_integer(id)) do
      {:ok, bet} ->
        conn
        |> put_status(:ok)
        |> json(%{
          status: "success",
          message: "Bet cancelled",
          data: serialize_bet(bet)
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Bet not found"})

      {:error, :forbidden} ->
        conn
        |> put_status(:forbidden)
        |> json(%{status: "error", message: "Cannot cancel another user's bet"})

      {:error, :cannot_cancel} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "Bet cannot be cancelled"})

      {:error, :game_closed} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "Cannot cancel: game already started or closed"})
    end
  end

  # Helper: serialize bet
  defp serialize_bet(%Bet{} = bet) do
    %{
      id: bet.id,
      user_id: bet.user_id,
      game_id: bet.game_id,
      stake: bet.stake,
      selection: bet.chosen_team,
      odds_at_bet: bet.odds_at_time,
      status: bet.status,
      payout: bet.payout,
      inserted_at: bet.inserted_at,
      updated_at: bet.updated_at
    }
  end

  # Placeholder plug for auth
  defp authenticate_user(conn, _opts) do
    # Assumes you already assign current_user in session or plug pipeline
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{status: "error", message: "Authentication required"})
      |> halt()
    end
  end
end
