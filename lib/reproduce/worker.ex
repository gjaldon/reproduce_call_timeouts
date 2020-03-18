defmodule Reproduce.Worker do
  use GenServer
  require Logger

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def test() do
    GenServer.call(__MODULE__, :test)
  end

  def test(n) do
    GenServer.call(__MODULE__, {:test, n})
  end

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_info(message, state) do
    Logger.info(inspect(message))
    {:noreply, state}
  end

  def handle_call(:test, _from, state) do
    Process.sleep(2)

    {:reply, state, state}
  end

  @impl true
  def handle_call({:test, n}, _from, state) do
    Enum.map(1..n, fn i -> Task.async(fn ->
        info = Redis.command!(["INFO"])
        Logger.info(inspect(info))
      end)
    end)

    {:reply, state, state}
  end
end
