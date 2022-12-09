defmodule SolutionDay9 do
  def load_input() do
    File.stream!("inputs/day9.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, " ", trim: true)))
    |> Stream.map(fn [dir, count] -> [dir, Integer.parse(count) |> elem(0)] end)
    |> Enum.to_list()
  end

  def solve1(input) do
    moves = do_moves(input, {0,0}, {0,0})
    MapSet.size(MapSet.new(moves))
  end

  defp do_moves([], _, tail), do: [tail]
  defp do_moves([move | rest], head, tail) do
    {new_head, new_tail, moved} = do_move(move, head, tail, [tail])
    moved ++ do_moves(rest, new_head, new_tail)
  end

  defp do_move([_, 0], head, tail, moved), do: {head, tail, moved}
  defp do_move([dir, count], head, tail, moved) do
    new_head = move_head(dir, head)
    new_tail = move_tail(new_head, tail)
    do_move([dir, count - 1], new_head, new_tail, moved ++ [new_tail])
  end

  defp move_head("U", {x, y}), do: {x, y + 1}
  defp move_head("D", {x, y}), do: {x, y - 1}
  defp move_head("R", {x, y}), do: {x + 1, y}
  defp move_head("L", {x, y}), do: {x - 1, y}

  defp move_tail({hx, hy}, {tx, ty}) when (hx == tx and abs(ty - hy) >= 2) do
    cond do
      hy > ty -> {tx, ty + 1}
      hy < ty -> {tx, ty - 1}
      true -> {tx, ty}
    end
  end

  defp move_tail({hx, hy}, {tx, ty}) when hy == ty and abs(tx - hx) >= 2 do
    cond do
      hx > tx -> {tx + 1, ty}
      hx < tx -> {tx - 1, ty}
      true -> {tx, ty}
    end
  end

  defp move_tail({hx, hy}, {tx, ty}) when (hy != ty and hx != tx and (abs(tx - hx) >= 2 or abs(ty - hy) >= 2)) do
    new_tx = cond do
      hx > tx -> tx + 1
      hx < tx -> tx - 1
      true -> tx
    end
    new_ty = cond do
      hy > ty -> ty + 1
      hy < ty -> ty - 1
      true -> ty
    end
    {new_tx, new_ty}
  end
  defp move_tail(_, tail), do: tail
end

input = SolutionDay9.load_input()
IO.inspect(input |> SolutionDay9.solve1())
