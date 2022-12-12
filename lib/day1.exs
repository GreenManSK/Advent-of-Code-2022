defmodule SolutionDay1 do
  def load_input() do
    File.stream!("inputs/day1.txt") |> Stream.map(&String.trim/1)
  end

  def solve1(input) do
    %{elves: elves} = count_elves2(input)
    elves |> Enum.max
  end

  def solve2(input) do
    %{elves: elves} = count_elves2(input)
    elves |> Enum.sort(&(&1 >= &2)) |> Enum.take(3) |> Enum.sum
  end

  defp count_elves2(input) do
    input |> List.foldr(%{sum: 0, elves: []}, &reduce/2)
  end

  defp reduce("", %{sum: sum, elves: elves}) do
    %{sum: 0, elves: elves ++ [sum]}
  end

  defp reduce(val, %{sum: sum, elves: elves}) do
    {int_val, _} = Integer.parse(val)
    %{sum: sum + int_val, elves: elves}
  end
end

input = SolutionDay1.load_input()
IO.inspect(input |> Enum.to_list |> SolutionDay1.solve1)
IO.inspect(input |> Enum.to_list |> SolutionDay1.solve2)
