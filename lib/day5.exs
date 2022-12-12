defmodule SolutionDay5 do
  def load_input() do
    {stacks, [_ | moves]} = File.stream!("inputs/day5.txt")
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
    |> Enum.split_while(&(&1 != ""))
    {
      stacks |> parse_stacks(),
      moves |> Enum.map(&parse_move/1)
    }
  end

  def solve1({stacks, moves}) do
    do_moves(stacks, moves, true)
    |> get_tops()
  end

  def solve2({stacks, moves}) do
    do_moves(stacks, moves, false)
    |> get_tops()
  end

  defp do_moves(stacks, [], _), do: stacks
  defp do_moves(stacks, [move | moves], reverse) do
    do_moves(stacks |> do_move(move, reverse), moves, reverse)
  end

  defp do_move(stack, {move, from, to}, reverse) do
    from_stack = stack |> elem(from - 1)
    to_stack = stack |> elem(to - 1)
    {from_take, from_rem} = Enum.split(from_stack, move)
    real_from_take = if reverse, do: from_take |> Enum.reverse(), else: from_take
    stack
    |> put_elem(from - 1, from_rem)
    |> put_elem(to - 1, real_from_take ++ to_stack)
  end

  defp get_tops(stacks) do
    stacks |> Tuple.to_list() |> Enum.map(&hd/1) |> Enum.join("")
  end

  defp parse_move(move) do
    [_, move, from, to] = Regex.run(~r/move (\d+) from (\d+) to (\d+)/, move)
    {Integer.parse(move) |> elem(0), Integer.parse(from) |> elem(0), Integer.parse(to) |> elem(0)}
  end

  defp parse_stacks(stacks) do
    stacks
    |> Enum.map(&String.replace(&1, ~r/    /, "-"))
    |> Enum.map(&String.replace(&1, ~r/( ?\[|\])/i, ""))
    |> Enum.map(&(String.split(&1, "", trim: true)))
    |> Enum.reverse() |> tl() |> Enum.reverse() # Get rid of number row
    |> Helpers.transpose()
    |> Enum.map(&Enum.filter(&1, fn x -> x != " " and x != "-" end))
    |> List.to_tuple()
  end
end

input = SolutionDay5.load_input()
IO.inspect(SolutionDay5.solve1(input))
IO.inspect(SolutionDay5.solve2(input))
