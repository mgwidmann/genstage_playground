defmodule GenstagePlayground do
  use Application
  require Integer

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: GenstagePlayground.Worker.start_link(arg1, arg2, arg3)
      worker(GenstagePlayground.Producer, [0]),
      worker(GenstagePlayground.ProducerConsumer, []),
      worker(GenstagePlayground.Consumer, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GenstagePlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def work() do
    GenstagePlayground.Consumer.register()
    GenstagePlayground.Consumer.begin()
    GenstagePlayground.Consumer.wait()
  end

  def flow() do
    # Producer generating numbers
    0
    |> Stream.iterate(fn i ->
      IO.puts "P Producing a new number"
      i + 1
    end)
    |> Stream.take(100_000)
    |> Flow.from_enumerable()
    |> Flow.partition()
    # Producer-Consumer filtering even numbers
    |> Flow.filter(fn i ->
      IO.puts "PC Filtering"
      Integer.is_even(i)
    end)
    |> Flow.partition()
    # Consumer printing out numbers
    |> Flow.each(fn i -> IO.puts "C Processing #{i}" end)
  end
end
