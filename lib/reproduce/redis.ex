defmodule Redis do
  use Supervisor

  @name __MODULE__
  @poolboy_wait_time :timer.seconds(5)
  @pool_name :rate_limit_redis_pool

  def start_link(state \\ []), do: Supervisor.start_link(@name, state)

  def init(_state) do
    pool_opts = [
      name: {:local, @pool_name},
      worker_module: Redix,
      size: 10,
      max_overflow: 32
    ]

    children = [
      :poolboy.child_spec(@pool_name, pool_opts, [])
    ]

    supervise(children, strategy: :one_for_one, name: @name)
  end

  def command(command, opts \\ []) do
    :poolboy.transaction(@pool_name, &Redix.command(&1, command, opts), @poolboy_wait_time)
  end

  def command!(command, opts \\ []) do
    :poolboy.transaction(@pool_name, &Redix.command!(&1, command, opts), @poolboy_wait_time)
  end

  def pipeline(commands, opts \\ []) do
    :poolboy.transaction(@pool_name, &Redix.pipeline(&1, commands, opts), @poolboy_wait_time)
  end

  def pipeline!(commands, opts \\ []) do
    :poolboy.transaction(@pool_name, &Redix.pipeline!(&1, commands, opts), @poolboy_wait_time)
  end
end
