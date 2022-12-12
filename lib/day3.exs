defmodule SolutionDay3 do
  def load_input() do
    File.stream!("inputs/day3.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, "", trim: true)))
  end

  def solve1(bags) do
    bags
    |> Stream.map(&(Enum.split(&1, round(length(&1) / 2))))
    |> Stream.map(&(find_common(&1)))
    |> Stream.map(&get_priority/1)
    |> Enum.sum()
  end

  def solve2(bags) do
    bags
    |> Enum.to_list()
    |> find_badges([])
    |> Enum.map(&get_priority/1)
    |> Enum.sum()
  end

  defp find_common({first, second}) do
    first_set = MapSet.new(first)
    Enum.find(second, fn x -> MapSet.member?(first_set, x) end)
  end

  defp get_priority(<<item_cp::utf8>>) do
    cond do
      item_cp >= ?a -> item_cp - ?a + 1
      true >= ?A -> item_cp - ?A + 27
    end
  end

  defp find_badges([], acc), do: acc
  defp find_badges([a,b,c | rest], acc) do
    b_set = MapSet.new(b)
    c_set = MapSet.new(c)
    badge = Enum.find(a, fn x -> MapSet.member?(b_set, x) and MapSet.member?(c_set, x) end)
    find_badges(rest, acc ++ [badge])
  end
end

input = SolutionDay3.load_input()
IO.inspect(input |> SolutionDay3.solve1)
IO.inspect(input |> SolutionDay3.solve2)
