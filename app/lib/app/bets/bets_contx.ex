defmodule App.Bets do
  import Ecto.Query, warn: false
  alias App.Repo
  alias App.Bets.Bet
  alias App.Games.Game
  alias App.Accounts.User
  require Decimal

  def place_bet(%User{id: user_id}, %{"game_id" => game_id, "stake" => stake, "selection" => selection}) do
    game = Repo.get!(Game, game_id)

    cond do
      game.status != "open" ->
        {:error, :game_closed}

      true ->
        odds = Map.get(game.odds, selection)
        if odds == nil do
          {:error, :invalid_selection}
        else
          attrs = %{
            "user_id" => user_id,
            "game_id" => game_id,
            "stake" => Decimal.new(stake),
            "selection" => selection,
            "odds_at_bet" => Decimal.new(odds)
          }

          %Bet{}
          |> Bet.changeset(attrs)
          |> Repo.insert()
        end
    end
  end

  def cancel_bet(%User{id: user_id}, bet_id) do
    bet = Repo.get(Bet, bet_id)
    cond do
      bet == nil -> {:error, :not_found}
      bet.user_id != user_id -> {:error, :forbidden}
      bet.status != "placed" -> {:error, :cannot_cancel}
      true ->
        # allow cancel only if game still open
        game = Repo.get!(Game, bet.game_id)
        if game.status != "open" do
          {:error, :game_closed}
        else
          bet
          |> Ecto.Changeset.change(status: "cancelled")
          |> Repo.update()
        end
    end
  end

  def list_bets_by_user(user_id) do
    Bet
    |> where([b], b.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload(:game)
  end

  def list_bets_by_game(game_id) do
    Bet
    |> where([b], b.game_id == ^game_id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  # settle bets for a game_id (synchronous)
  def settle_bets_for_game(game_id) do
    game = Repo.get!(Game, game_id)
    result = game.result
    bets = list_bets_by_game(game_id)

    Repo.transaction(fn ->
      Enum.each(bets, fn bet ->
        cond do
          bet.status in ["cancelled", "won", "lost"] ->
            :ok

          bet.selection == result ->
            # win: payout = stake * odds_at_bet
            payout = Decimal.mult(bet.stake, bet.odds_at_bet) |> Decimal.round(2)
            bet
            |> Ecto.Changeset.change(status: "won", payout: payout)
            |> Repo.update!()

            # send email to user (async or fire-and-forget)
            App.Mailer.send_bet_result_email(bet.user_id, bet.id, "won")

          true ->
            # lost: payout 0
            bet
            |> Ecto.Changeset.change(status: "lost", payout: Decimal.new("0.0"))
            |> Repo.update!()

            App.Mailer.send_bet_result_email(bet.user_id, bet.id, "lost")
        end
      end)
    end)

    # return computed profit
    compute_profit_for_game(game_id)
  end

  def compute_profit_for_game(game_id) do
    bets = list_bets_by_game(game_id)
    total_stakes = Enum.reduce(bets, Decimal.new("0.0"), fn b, acc -> Decimal.add(acc, b.stake) end)
    total_payouts = Enum.reduce(bets, Decimal.new("0.0"), fn b, acc -> Decimal.add(acc, b.payout) end)
    Decimal.sub(total_stakes, total_payouts) |> Decimal.round(2)
  end
end
