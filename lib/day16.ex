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
    graph = to_graph(rooms)
    with_flow = Map.to_list(rooms) |> Enum.filter(fn {_, {flow, _}} -> flow > 0 end) |> Enum.map(fn {room, _} -> room end)
    distances = create_distance_map(graph, ["AA" | with_flow], %{})

    get_best_flow("AA", distances, rooms, with_flow, 30, 0, MapSet.new())
  end

  def solve2(rooms) do
    graph = to_graph(rooms)
    with_flow = Map.to_list(rooms) |> Enum.filter(fn {_, {flow, _}} -> flow > 0 end) |> Enum.map(fn {room, _} -> room end)
    distances = create_distance_map(graph, ["AA" | with_flow], %{})

    time = 26
    {solution, memory} = get_best_flow2(["AA", "AA"], distances, rooms, with_flow, [time, time], 0, MapSet.new(), %{})
    solution
  end

  defp get_best_flow2(_, _, _, _, [remaining_a, remaining_b], pressure, _, memory) when remaining_a <= 0 and remaining_b <= 0, do: {pressure, memory}
  defp get_best_flow2([pos_a, pos_b], distances, rooms, with_flow, [remaining_a, remaining_b], pressure, open, memory) when remaining_a <= 0 do
    key = get_key(pos_a, pos_b, remaining_a, remaining_b, open)
    if Map.has_key?(memory, key) do
      {memory[key], memory}
    else
      new_pressure = get_best_flow(pos_b, distances, rooms, with_flow, remaining_b, pressure, open)
      {new_pressure, Map.put(memory, key, new_pressure)}
    end
  end
  defp get_best_flow2([pos_a, pos_b], distances, rooms, with_flow, [remaining_a, remaining_b], pressure, open, memory) when remaining_b <= 0 do
    key = get_key(pos_a, pos_b, remaining_a, remaining_b, open)
    if Map.has_key?(memory, key) do
      {memory[key], memory}
    else
      new_pressure = get_best_flow(pos_a, distances, rooms, with_flow, remaining_a, pressure, open)
      {new_pressure, Map.put(memory, key, new_pressure)}
    end
  end
  defp get_best_flow2([pos_a, pos_b], distances, rooms, with_flow, [remaining_a, remaining_b], pressure, open, memory) do
    key = get_key(pos_a, pos_b, remaining_a, remaining_b, open)

    if (length(with_flow) + 1 == MapSet.size(open)) do
      {pressure, memory}
    else
      if Map.has_key?(memory, key) do
        {memory[key], memory}
      else
        {new_open, new_remaining_a, new_pressure} = open_position(pos_a, open, remaining_a, rooms, pressure)
        {new_open, new_remaining_b, new_pressure} = open_position(pos_b, new_open, remaining_b, rooms, new_pressure)

        valid_destinations = with_flow |> Enum.filter(fn d -> not MapSet.member?(new_open, d) end)

        moves = (if length(valid_destinations) == 1 do
                   [valid_move] = valid_destinations
                   [{valid_move, pos_b}, {pos_a, valid_move}]
                 else
                   (for x <- valid_destinations, y <- valid_destinations, x != y, do: {x,y}) |> Enum.filter(fn {a,b} -> a != b end)
                 end)

        {new_best_pressure, new_memory} = Enum.reduce(moves, {new_pressure, memory}, fn {a,b}, {current_best, memory} ->
          distance_a = if a == pos_a, do: 0, else: distances[{a, pos_a}]
          distance_b = if b == pos_b, do: 0, else: distances[{pos_b, b}]
          {sub_pressure, new_memory} = get_best_flow2([a, b], distances, rooms, with_flow, [new_remaining_a - distance_a, new_remaining_b - distance_b], 0, new_open, memory)
          {max(sub_pressure + new_pressure, current_best), new_memory}
        end)
        {new_best_pressure, Map.put(new_memory, key, new_best_pressure)}
      end
    end
  end

  defp get_key(pos_a, pos_b, remaining_a, remaining_b, open) do
    if pos_a > pos_b do
      {pos_a, pos_b, remaining_a, remaining_b, open}
    else
      {pos_b, pos_a, remaining_b, remaining_a, open}
    end
  end

  defp get_best_flow(_, _, _, _, remaining_time, pressure, _) when remaining_time <= 0, do: pressure
  defp get_best_flow(position, distances, rooms, with_flow, remaining_time, pressure, open) do
    {new_open, new_remaining_time, new_pressure} = open_position(position, open, remaining_time, rooms, pressure)

    valid_destinations = with_flow |> Enum.filter(fn d -> not MapSet.member?(new_open, d) end)

    complete_pressure = Enum.reduce(valid_destinations, new_pressure, fn dest, current_best ->
      distance = distances[{position, dest}]
      sub_pressure = get_best_flow(dest, distances, rooms, with_flow, new_remaining_time - distance, new_pressure, new_open)
      max(current_best, sub_pressure)
    end)
    complete_pressure
  end

  defp open_position(position, open, remaining_time, rooms, pressure) do
    new_open = MapSet.put(open, position)
    new_remaining_time = remaining_time - (if position == "AA", do: 0, else: 1)
    {flow, _} = rooms[position]
    new_pressure = pressure + flow * new_remaining_time
    {new_open, new_remaining_time, new_pressure}
  end

  defp to_graph(rooms) do
    edges = Enum.reduce(Map.to_list(rooms), [], fn {room, {_, neighs}}, edges -> Enum.map(neighs, fn n -> {room, n} end) ++ edges end)
    Graph.new() |> Graph.add_edges(edges)
  end

  defp create_distance_map(_, [], distances), do: distances
  defp create_distance_map(graph, [current | rest], distances) do
    distances = Enum.reduce(rest, distances, fn dest, distances ->
      distance = length(Graph.get_shortest_path(graph, current, dest)) - 1
      Map.put(distances, {current, dest}, distance) |> Map.put({dest, current}, distance)
    end)
    create_distance_map(graph, rest, distances)
  end

end
