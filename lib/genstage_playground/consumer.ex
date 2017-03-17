defmodule GenstagePlayground.Consumer do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  def init(_) do
    {:consumer, {nil, nil, nil}, subscribe_to: [GenstagePlayground.ProducerConsumer]}
  end

  def handle_subscribe(:producer, _options, from, _state) do
    {:manual, {from, nil}}
  end

  def begin() do
    GenServer.cast(__MODULE__, :begin)
  end

  def register() do
    GenServer.call(__MODULE__, :register)
  end

  def wait() do
    receive do
      :done -> :done
    end
  end

  def handle_call(:register, {notify, _ref}, {from, nil}) do
    {:reply, :ok, [], {from, notify}}
  end

  def handle_cast(:begin, {from, _notify} = state) do
    IO.puts "C Beginning"
    GenStage.ask(from, 1)
    {:noreply, [], state}
  end

  def handle_events([:done], _from, {_from, notify} = state) do
    IO.puts "C Received done"
    send(notify, :done)
    {:noreply, [], state}
  end

  def handle_events(events, from, state) do
    for event <- events do
      IO.puts "C Processing event #{event}"
    end

    GenStage.ask(from, 1)
    # As a consumer we never emit events
    {:noreply, [], state}
  end
end
