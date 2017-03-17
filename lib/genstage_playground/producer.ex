defmodule GenstagePlayground.Producer do
  use GenStage

  def start_link(initial \\ 0) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(counter), do: {:producer, counter}

  def handle_demand(_demand, count) when count >= 100_000 do
    IO.puts "P stopping at #{inspect count}"
    {:noreply, [:done], count}
  end

  def handle_demand(demand, count) do
    IO.puts "P demand of #{demand}"
    events = Enum.to_list(count..count + demand - 1)
    {:noreply, events, (count + demand)}
  end
end
