defmodule SolutionDay6 do
  def load_input() do
    File.stream!("inputs/day6.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, "", trim: true)))
    |> Enum.to_list()
    |> List.flatten()
  end

  def solve(input, marker_len) do
    (input |> find_marker(0, marker_len)) + marker_len
  end

  defp find_marker([], _, _), do: -1
  defp find_marker([s | rest], index, marker_len) do
    candidate = [s] ++ Enum.take(rest, marker_len - 1)
    unique_chars = MapSet.size(MapSet.new(candidate))
    cond do
      unique_chars == marker_len -> index
      true -> find_marker(rest, index + 1, marker_len)
    end
  end
end

input = SolutionDay6.load_input()
IO.inspect(input |> SolutionDay6.solve(4))
IO.inspect(input |> SolutionDay6.solve(14))
