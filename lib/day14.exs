defmodule SolutionDay14 do
  @sand_source {500, 0}

  def load_input() do
    File.stream!("inputs/day14.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, " -> ", trim: true)))
    |> Stream.map(
         &Enum.map(&1, fn x ->
           String.split(x, ",", trim: true)
           |> Enum.map(fn y -> Integer.parse(y) |> elem(0) end)
         end)
       )
    |> Enum.to_list()
  end

  def solve1(input) do
    min_max = get_min_max(input)
    board = fill_board(create_board(min_max), input)
    throw_sand(board, 0, &find_sand_fall_point1/2)
  end

  def solve2(input) do
    min_max = get_min_max(input)
    {_, {_, max_y}} = min_max
    board = fill_board(create_board(min_max), input)
    throw_sand(board, 0, &find_sand_fall_point2(&1, &2, max_y + 2)) + 1
  end

  defp throw_sand(board, count, find_fall_point) do
    point = find_fall_point.(board, @sand_source)
    case point do
      :outside -> count
      @sand_source -> count
      _ -> throw_sand(Map.update(board, point, "o", fn _ -> "o" end), count + 1, find_fall_point)
    end
  end

  defp find_sand_fall_point1(board, sand) do
    next_point = next_move(board, sand)
    cond do
      next_point == :none -> sand
      not exists?(board, next_point) -> :outside
      true -> find_sand_fall_point1(board, next_point)
    end
  end

  defp find_sand_fall_point2(board, sand, floor_y) do
    {_, sand_y} = sand
    next_point = next_move(board, sand)
    cond do
      sand_y + 1 == floor_y -> sand
      next_point == :none -> sand
      true -> find_sand_fall_point2(board, next_point, floor_y)
    end
  end

  defp next_move(board, {x,y}) do
    cond do
      is_empty?(board, {x,y+1}) -> {x,y+1}
      is_empty?(board, {x-1,y+1}) -> {x-1,y+1}
      is_empty?(board, {x+1,y+1}) -> {x+1,y+1}
      true -> :none
    end
  end

  defp exists?(board, point) do
    Map.has_key?(board, point)
  end

  defp is_empty?(board, point) do
    not exists?(board, point) or board[point] == "."
  end

  defp create_board({{min_x, min_y}, {max_x, max_y}}) do
    keys = for x <- min_x..max_x, y <- min_y..max_y, do: {{x, y}, "."}
    Map.new(keys)
  end

  defp fill_board(board, input) do
    Enum.reduce(input, board, fn lines, board -> fill_lines(board, lines) end)
  end

  defp fill_lines(board, []), do: board
  defp fill_lines(board, [_]), do: board
  defp fill_lines(board, [from, to | rest]) do
    [from_x, from_y] = from
    [to_x, to_y] = to
    fills = for x <- from_x..to_x, y <- from_y..to_y, do: {{x, y}, "#"}
    new_board = Enum.reduce(fills, board, fn {coord, value}, board -> Map.replace!(board, coord, value) end)
    fill_lines(new_board, [to | rest])
  end

  defp get_min_max(input) do
    Enum.reduce(input, fn x, acc -> x ++ acc end)
    |> Enum.reduce({{9999999, 0}, {0,0}}, fn [x,y], {{min_x, min_y}, {max_x, max_y}} ->
      {
        {min(min_x, x),min(min_y, y)},
        {max(max_x, x),max(max_y, y)}
      }
    end)
  end
end

input = SolutionDay14.load_input()
IO.inspect(input |> SolutionDay14.solve1())
IO.inspect(input |> SolutionDay14.solve2())
