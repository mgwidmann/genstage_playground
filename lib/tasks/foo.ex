defmodule Mix.Tasks.Foo do
  use Mix.Task

  def run(_) do
    {:ok, _started} = Application.ensure_all_started(:genstage_playground)
  end
end
