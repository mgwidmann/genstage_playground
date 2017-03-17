defmodule GenstagePlayground do
  use Application

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
end
