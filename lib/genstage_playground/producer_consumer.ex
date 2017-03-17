defmodule GenstagePlayground.ProducerConsumer do
  use GenStage
  require Integer

  def start_link do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [GenstagePlayground.Producer]}
  end

  def handle_events([:done], _from, state) do
    IO.puts "PC Received done event"
    {:noreply, [:done], state}
  end

  def handle_events(events, _from, state) do
    IO.puts "PC handling #{length(events)} events from producer"
    numbers =
      events
      |> Enum.filter(&Integer.is_even/1)

    {:noreply, numbers, state}
  end
end
