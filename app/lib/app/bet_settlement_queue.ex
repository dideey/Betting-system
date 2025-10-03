defmodule App.BetSettlementQueue do
  use GenServer

  @name __MODULE__

  # public API
  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: @name)
  def enqueue(task), do: GenServer.cast(@name, {:enqueue, task})

  # server
  def init(:ok), do: {:ok, %{queue: :queue.new(), running: false}}

  def handle_cast({:enqueue, task}, state) do
    newq = :queue.in(task, state.queue)
    schedule_process()
    {:noreply, %{state | queue: newq}}
  end

  def handle_info(:process, %{queue: q} = state) do
    case :queue.out(q) do
      {:empty, _} ->
        {:noreply, %{state | running: false}}
      {{:value, {:settle_game, game_id}}, newq} ->
        # do settlement async so GenServer loop not blocked
        Task.start(fn ->
          App.Bets.settle_bets_for_game(game_id)
        end)
        schedule_process()
        {:noreply, %{state | queue: newq}}
      {{:value, _other}, newq} ->
        schedule_process()
        {:noreply, %{state | queue: newq}}
    end
  end

  defp schedule_process(), do: Process.send_after(self(), :process, 100)
end
