defmodule SolutionDay16 do
  def load_input() do
    File.stream!("inputs/day16.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_input_line/1)
    |> Map.new()
  end

  defp parse_input_line(line) do
    [_, room, flow, paths] = Regex.run(~r/^Valve (.*) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/, line)
    {
      room,
      {Integer.parse(flow) |> elem(0), String.split(paths, ", ", trim: true)}
    }
  end

  def solve1(rooms) do
    {result, _} = find_largest_flow_from_memory("AA", rooms, 30, 0, MapSet.new(), %{})
    result
  end

  defp find_largest_flow(_, _, 0, potential, _, memory), do: {potential, memory}
  defp find_largest_flow(room, rooms, remaining_time, potential, open, memory) do
    is_open = MapSet.member?(open, room)
    {flow, next_rooms} = rooms[room]

    # do_not_open_result
    {not_open_best, memory} = Enum.reduce(next_rooms, {0, memory}, fn room, {current_best, memory} ->
      {current_p, memory} = find_largest_flow_from_memory(room, rooms, remaining_time - 1, 0, open, memory)
      {max(current_best, current_p + potential), memory}
    end)

    # open result
    if is_open or remaining_time == 1 or flow == 0 do
      {not_open_best, memory}
    else
      new_open = MapSet.put(open, room)
      new_potential = potential + flow * (remaining_time - 1)
      {open_best, memory} = Enum.reduce(next_rooms, {0, memory}, fn room, {current_best, memory} ->
        {current_p, memory} = find_largest_flow_from_memory(room, rooms, remaining_time - 2, 0, new_open, memory)
        {max(current_best, current_p + new_potential), memory}
      end)
      {max(not_open_best, open_best), memory}
    end
  end

  defp find_largest_flow_from_memory(room, rooms, remaining_time, potential, open, memory) do
    key = {room, remaining_time, open}
    if Map.has_key?(memory, key) do
      p = memory[key]
      {p,memory}
    else
      {p,memory} = find_largest_flow(room, rooms, remaining_time, potential, open, memory)
      new_memory = Map.put(memory, key, p)
      {p,new_memory}
    end
  end
end
