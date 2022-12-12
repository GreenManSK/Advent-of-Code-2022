defmodule SolutionDay12 do

  def load_input() do
    File.stream!("inputs/day12.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, "", trim: true)))
    |> Stream.map(&List.to_tuple(&1))
    |> Enum.to_list()
    |> List.to_tuple()
  end

  def solve1(input) do
    edges = get_edges(input)
    graph = Graph.new |> Graph.add_edges(edges)
    start_coords = find_node(input, "S")
    end_coords = find_node(input, "E")
    path = Graph.dijkstra(graph, start_coords, end_coords)
    path |> Enum.map(&(get_height(input, &1)))
    length(path) - 1
  end

  defp get_edges(input) do
    height = tuple_size(input) - 1
    width = tuple_size(elem(input, 0)) - 1
    coords = for x <- 0..width, y <- 0..height, do: {x, y}
    coords_to_edges(input, coords, width, height, [])
  end

  defp find_node(input, node_height) do
    height = tuple_size(input) - 1
    width = tuple_size(elem(input, 0)) - 1
    coords = for x <- 0..width, y <- 0..height, do: {x, y}
    [end_coords | _] = coords |> Enum.filter(fn coord -> get_height(input, coord) == node_height end)
    end_coords
  end

  defp coords_to_edges(_, [], _, _, edges), do: edges
  defp coords_to_edges(map, [coord | rest], width, height, edges) do
    {x, y} = coord
    moves = [{0,1},{1,0},{0,-1},{-1,0}]
    valid_moves = moves
      |> Enum.map(fn {dx,dy} -> {x+dx,y+dy} end)
      |> Enum.filter(&(is_valid(&1, width, height)))
      |> Enum.filter(&(can_move(map, coord, &1)))

    new_edges = valid_moves |> Enum.map(&({coord, &1}))
    coords_to_edges(map, rest, width, height, edges ++ new_edges)
  end

  defp can_move(map, from, to) do
    from_height = get_height(map, from)
    to_height = get_height(map, to)
    from_height == to_height
    or get_next_height(from_height) == to_height
    or get_next_height(to_height) == from_height
    or is_lower(from_height, to_height)
  end
  defp is_valid({x, y}, width, height) do
    0 <= x and x <= width and 0 <= y and y <= height
  end

  def get_height(map, {x,y}), do: elem(elem(map, y), x)

  def get_next_height("S"), do: "a"
  def get_next_height("z"), do: "E"
  def get_next_height(<<item_cp::utf8>>), do: <<item_cp + 1::utf8>>

  def is_lower("S", _), do: false
  def is_lower("E", _), do: true
  def is_lower(_, "S"), do: true
  def is_lower(_, "E"), do: false
  def is_lower(<<from::utf8>>, <<to::utf8>>), do: from > to
end
