defmodule SolutionDay2 do
  @win_map %{"A" => "C", "B" => "A", "C" => "B", "X" => "C", "Y" => "A", "Z" => "B"}
  @lose_map %{"C" => "A", "A" => "B", "B" => "C"}

  def load_input() do
    File.stream!("inputs/day2.txt") |> Stream.map(&String.trim/1) |> Stream.map(&(String.split(&1, " ")))
  end

  def solve1(input) do
    input |> Stream.map(&score1/1) |> Enum.sum()
  end

  def solve2(input) do
    input |> Stream.map(&score2/1) |> Enum.sum()
  end

  defp score1([a, b]) do
    win_score1(a,b) + played_score(b)
  end

  defp score2([a, b]) do
    win_score2(b) + played_score(what_to_play(b, a))
  end

  defp win_score1(a, b) do
    a_beats = @win_map[a]
    b_beats = @win_map[b]
    cond do
      b_beats == a -> 6
      a_beats == b_beats -> 3
      true -> 0
    end
  end

  defp win_score2("X"), do: 0
  defp win_score2("Y"), do: 3
  defp win_score2("Z"), do: 6

  defp what_to_play("X", a), do: @win_map[a]
  defp what_to_play("Y", a), do: a
  defp what_to_play("Z", a), do: @lose_map[a]

  defp played_score("X"), do: 1
  defp played_score("Y"), do: 2
  defp played_score("Z"), do: 3
  defp played_score("A"), do: 1
  defp played_score("B"), do: 2
  defp played_score("C"), do: 3
end

input = SolutionDay2.load_input()
IO.puts(input |> SolutionDay2.solve1())
IO.puts(input |> SolutionDay2.solve2())
