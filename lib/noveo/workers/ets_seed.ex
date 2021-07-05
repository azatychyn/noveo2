defmodule Noveo.Workers.EtsSeed do
  use GenServer

  require Logger

  def name, do: :ets_seed_worker

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{}, name: name())
  end

  def init(state) do
    send(self(), :fill_professions)
    send(self(), :fill_jobs)
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    schedule_work()
    {:noreply, state}
  end

  def handle_info(:fill_professions, state) do
    spawn(&fill_professions/0)
    {:noreply, state}
  end

  def handle_info(:fill_jobs, state) do
    spawn(&fill_jobs/0)
    {:noreply, state}
  end

  defp schedule_work(time \\ 5_000) do
    Process.send_after(self(), :work, time)
  end

  defp fill_professions() do
    Logger.info("Inserting professions...")
    Noveo.Employment.parse_professions()
    Logger.info("Inserting professions finished")
  end

  defp fill_jobs() do
    Logger.info("Inserting jobs...")
    Noveo.Employment.parse_jobs()
    Logger.info("Inserting jobs finished")
  end
end
