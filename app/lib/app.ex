defmodule App do
	 
	@doc """
	This is just a test function that returns a constant value

  ## Example

			iex>App.test
			"HelloWorld"

	"""
	def test do
		"Hello" <> "World"
	end

  def test1 do
		Enum.member?([1,2,4], 2)
  end

  def what do
		IO.puts "Hello"
    :crypto.hash(:md5, "asdf")
	  |> :binary.bin_to_list
	  |> Enum.chunk(3) 
	  |> Enum.map(fn [a, b, c] -> [a,b,c,b,a] end) 
	  |> List.flatten 
	  |> Enum.with_index 
	  |> Enum.filter(fn {val, _} -> rem(val, 2) == 0 end)

  end

	def fib(0), do: 0
	def fib(1), do: 1
	
	def fib(n) do
		tail_fib(n, 1, 0, 1)
	end

	defp tail_fib(n, counter, _prev_fib, current_fib) when n == counter, do: current_fib

	defp tail_fib(n, counter, prev_fib, current_fib) do
		tail_fib(n, counter + 1, current_fib, prev_fib + current_fib)
	end

	def mainFunc do
		first = %Benchmark{counter: 1, times: 2}
		IO.inspect first
	end
end
