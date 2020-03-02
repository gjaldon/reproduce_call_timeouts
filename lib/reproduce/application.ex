defmodule Reproduce.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Reproduce.Worker.start_link(arg)
      {Redis, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Reproduce.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def test() do
    Enum.each(1..100, fn i -> Task.async(fn ->
        info = Redis.command!(["INFO"])
        IO.inspect(i)
      end)
    end)
  end
end
