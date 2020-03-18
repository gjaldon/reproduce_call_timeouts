defmodule Redis do
  use Supervisor

  @poolboy_wait_time :timer.seconds(5)
  @pool_names [
    :rate_limit_pool,
    :rate_limit_pool_1,
    :rate_limit_pool_2,
    :rate_limit_pool_3,
    :rate_limit_pool_4
  ]

  def start_link([]), do: Supervisor.start_link(__MODULE__, [])

  def init([]) do
    children =
      Enum.map(@pool_names, fn pool_name ->
        pool_opts = [
          name: {:local, pool_name},
          worker_module: Redix,
          size: 20,
          max_overflow: 20
        ]

        :poolboy.child_spec(pool_name, pool_opts, [])
      end)

    supervise(children, strategy: :one_for_one, name: __MODULE__)
  end

  def pool() do
    Enum.random(@pool_names)
  end

  def command(command, opts \\ []) do
    :poolboy.transaction(pool(), &Redix.command(&1, command, opts), @poolboy_wait_time)
  end

  def command!(command, opts \\ []) do
    :poolboy.transaction(pool(), &Redix.command!(&1, command, opts), @poolboy_wait_time)
  end

  def pipeline(commands, opts \\ []) do
    :poolboy.transaction(pool(), &Redix.pipeline(&1, commands, opts), @poolboy_wait_time)
  end

  def pipeline!(commands, opts \\ []) do
    :poolboy.transaction(pool(), &Redix.pipeline!(&1, commands, opts), @poolboy_wait_time)
  end
end
