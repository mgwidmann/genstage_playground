defmodule GenstagePlayground.Consumer do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  def init(_) do
    {:consumer, nil, subscribe_to: [GenstagePlayground.ProducerConsumer]}
  end

  def handle_subscribe(:producer, _options, producer, _state) do
    {:manual, {producer, nil}}
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

  def handle_call(:register, {notify, _ref}, {producer, nil}) do
    {:reply, :ok, [], {producer, notify}}
  end

  def handle_cast(:begin, {producer, _notify} = state) do
    IO.puts "C Beginning"
    GenStage.ask(producer, 1)
    {:noreply, [], state}
  end

  def handle_events([:done], _from, {_producer, notify} = state) do
    IO.puts "C Received done"
    send(notify, :done)
    {:noreply, [], state}
  end

  def handle_events(events, _from, {producer, _notify} = state) do
    for event <- events do
      IO.puts "C Processing event #{event}"
    end

    GenStage.ask(producer, 1)
    # As a consumer we never emit events
    {:noreply, [], state}
  end
end
