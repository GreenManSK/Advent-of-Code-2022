defmodule SolutionDay15 do
  def load_input() do
    File.stream!("inputs/day15.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_input_line/1)
    |> Enum.to_list()
  end

  def solve1(input, result_y) do
    (fill_line(input, result_y, []) |> Enum.map(&interval_size/1) |> Enum.sum()) - MapSet.size(stuff_on_line(input, result_y, MapSet.new()))
  end

  def solve2(input, limit_y) do
    case find_missing(input, limit_y, 0) do
     {x,y} -> x * 4000000 + y
      _ -> "fek"
    end
  end

  defp find_missing(_, limit_y, current_y) when limit_y < current_y, do: nil
  defp find_missing(input, limit_y, current_y) do
    line = fill_line(input, current_y, []) |> Enum.filter(fn {start, ends} -> not (ends < 0 or start > limit_y) end) |> Enum.sort_by(fn {s,_} -> s end)
    if Enum.count(line) > 1 do
      [{_,end_x} | _] = line
      {end_x + 1, current_y}
    else
      find_missing(input, limit_y, current_y + 1)
    end
  end

  defp stuff_on_line([], _, result), do: result
  defp stuff_on_line([{sensor, beacon} | rest], result_y, result) do
    new_result = add_to_result(result, sensor, result_y) |> add_to_result(beacon, result_y)
    stuff_on_line(rest, result_y, new_result)
  end

  defp add_to_result(result, {x,y}, result_y) when y == result_y, do: MapSet.put(result, {x,y})
  defp add_to_result(result, _, _), do: result

  defp fill_line([], _, result) do
    result |> Enum.sort_by(fn {s,_} -> s end) |> reduce_intervals([])
  end
  defp fill_line([{sensor, beacon} | rest], result_y, result) do
    distance = distance(sensor, beacon)
    {sx, sy} = sensor
    to_result_y = abs(sy - result_y)
    remaining_distance = distance - to_result_y

    new_result = add_point(result, sensor, result_y) |> add_point(beacon, result_y)

    if remaining_distance >= 0 do
      fill_line(rest, result_y, [{sx - remaining_distance, sx + remaining_distance} | new_result])
    else
      fill_line(rest, result_y, new_result)
    end
  end

  defp add_point(result, {x,y}, result_y) when y == result_y, do: [{x,y} | result]
  defp add_point(result, _, _), do: result

  defp reduce_intervals([], result), do: result
  defp reduce_intervals([last], result), do: [last | result]
  defp reduce_intervals([{a_start, a_end}, {b_start, b_end} | rest], result) when b_start <= a_end, do: reduce_intervals([{a_start, max(a_end, b_end)} | rest], result)
  defp reduce_intervals([a | rest], result), do: reduce_intervals(rest, [a | result])

  defp interval_size({start, ends}), do: abs(start) + abs(ends) + 1

  defp distance({sx,sy},{bx,by}) do
    abs(sx - bx) + abs(sy - by)
  end

  defp parse_input_line(line) do
    [_, sx, sy, bx, by] = Regex.run(~r/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/, line)
    {{parse_coord(sx),parse_coord(sy)},{parse_coord(bx),parse_coord(by)}}
  end

  defp parse_coord(coord) do
    Integer.parse(coord) |> elem(0)
  end
end

input = SolutionDay15.load_input()
IO.inspect(input |> SolutionDay15.solve1(2000000))
IO.inspect(input |> SolutionDay15.solve2(4000000))
