defmodule SolutionDay4 do
  def load_input() do
    File.stream!("inputs/day4.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(
         &(String.split(&1, ",", trim: true))
         |> Enum.map(fn x ->
           String.split(x, "-")
           |> Enum.map(fn y -> Integer.parse(y) |> elem(0) end)
         end)
       )
  end

  def solve1(sections) do
    sections |> Enum.filter(&contain_each_other/1) |> Enum.count()
  end

  def solve2(sections) do
    sections |> Enum.filter(&overlap_each_other/1) |> Enum.count()
  end

  defp contain_each_other([first, second]) do
    contains(first, second) or contains(second, first)
  end

  defp contains([fs, fe], [ss, se]) do
    fs <= ss and se <= fe
  end

  defp overlap_each_other([first, second]) do
    overlap(first, second) or overlap(second, first)
  end

  defp overlap([fs, fe], [ss, se]) do
    (fs <= ss and ss <= fe) or (fs <= se and se <= fe)
  end
end

input = SolutionDay4.load_input()
IO.puts(input |> SolutionDay4.solve1())
IO.puts(input |> SolutionDay4.solve2())
