defmodule Benchmark do
  def measure(function) do
    function
    |> :timer.tc
    |> elem(0)
  end

  defstruct counter: 0, times: 0
end