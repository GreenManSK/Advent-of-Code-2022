defmodule SolutionDay1 do
  def load_input() do
    File.stream!("inputs/day1.txt") |> Stream.map(&String.trim/1)
  end

  def solve1(input) do
    count_elves(input, [], 0) |> Enum.max
  end

  def solve2(input) do
    count_elves(input, [], 0) |> Enum.sort(&(&1 >= &2)) |> Enum.take(3) |> Enum.sum
  end

  defp count_elves([], elves, sum) do
    elves ++ [sum]
  end

  defp count_elves(["" | rest], elves, sum) do
    count_elves(rest, elves ++ [sum], 0)
  end

  defp count_elves([val | rest], elves, sum) do
    {int_val, _} = Integer.parse(val)
    count_elves(rest, elves, sum + int_val)
  end
end

input = SolutionDay1.load_input()
IO.inspect(input |> Enum.to_list |> SolutionDay1.solve1)
IO.inspect(input |> Enum.to_list |> SolutionDay1.solve2)
