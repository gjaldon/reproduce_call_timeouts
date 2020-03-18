defmodule Reproduce.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Reproduce.Worker.start_link(arg)
      {Reproduce.Worker, []},
      {Redis, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Reproduce.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def test do
    Enum.map(1..20_000, fn i -> Task.async(fn -> Reproduce.Worker.test() end) end)
  end

  def message_queue_len do
    Reproduce.Worker
    |> GenServer.whereis()
    |> Process.info(:message_queue_len)
  end
end
