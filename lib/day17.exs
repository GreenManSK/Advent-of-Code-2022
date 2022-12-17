defmodule SolutionDay16 do
  @line [{0,0},{1,0},{2,0},{3,0}]
  @plus [{1,0},{0,1},{1,1},{2,1},{1,2}]
  @l_piece [{0,0},{1,0},{2,0},{2,1},{2,2}]
  @i_piece [{0,0},{0,1},{0,2},{0,3}]
  @square [{0,0},{1,0},{0,1},{1,1}]
  @order [@line,@plus,@l_piece,@i_piece,@square]

  @bottom_y 0
  @grid_x_bounds [0,6]

  def load_input() do
    File.stream!("inputs/day17.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, "", trim: true)))
    |> Enum.to_list()
  end

  def solve(input,n) do
    fallen = throw_n_pieces(n,[],{input,0},@order,@bottom_y,@grid_x_bounds)
    (List.flatten(fallen) |> Enum.map(fn {_,y} -> y end) |> Enum.max()) + 1
  end

  defp throw_n_pieces(0,fallen,_,_,_,_), do: fallen
  defp throw_n_pieces(n,fallen,input,[],bottom_y,grid_x_bounds), do: throw_n_pieces(n,fallen,input,@order,bottom_y,grid_x_bounds)
  defp throw_n_pieces(n,fallen,{input,pivot},order,bottom_y,grid_x_bounds) when tuple_size(input) < pivot, do: throw_n_pieces(n,fallen,{input,0},order,bottom_y,grid_x_bounds)
  defp throw_n_pieces(n,fallen,input,[piece | next_pieces],bottom_y,grid_x_bounds) do
    root = next_start(fallen,{2,3})
    real_shape = to_real_coords(piece, root)

#    IO.inspect("------------")
#    IO.inspect({root, real_shape})

    {fallen_shape, new_input} = move_while_not_crashed(real_shape, fallen, input,bottom_y,grid_x_bounds)
    new_fallen = [fallen_shape | (fallen)]
    throw_n_pieces(n - 1,new_fallen,new_input,next_pieces,bottom_y,grid_x_bounds)
  end

  defp move_while_not_crashed(shape, fallen, {input, pivot}, bottom_y, grid_x_bounds) when tuple_size(input) <= pivot do
    move_while_not_crashed(shape, fallen, {input, 0}, bottom_y, grid_x_bounds)
  end
  defp move_while_not_crashed(shape, fallen, {input, pivot}, bottom_y, grid_x_bounds) do
    side_move = if elem(input, pivot) == ">", do: :right, else: :left
    side_moved_shape = move(shape, side_move)

    shape = if crashed?(side_moved_shape, fallen, bottom_y, grid_x_bounds), do: shape, else: side_moved_shape
    new_pivot = pivot + 1

#    IO.inspect({"side",shape,side_move})
    down_moved_shape = move(shape, :down)
#    IO.inspect({"down",down_moved_shape})

    if crashed?(down_moved_shape, fallen, bottom_y, grid_x_bounds) do
      {shape, {input, new_pivot}}
    else
      move_while_not_crashed(down_moved_shape, fallen, {input, new_pivot}, bottom_y, grid_x_bounds)
    end
  end

  def move(shape, :left), do: Enum.map(shape, fn {x,y} -> {x-1,y} end)
  def move(shape, :right), do: Enum.map(shape, fn {x,y} -> {x+1,y} end)
  def move(shape, :down), do: Enum.map(shape, fn {x,y} -> {x,y-1} end)

  def to_real_coords(shape, {rx,ry}), do: Enum.map(shape, fn {x,y} -> {x+rx,y+ry} end)

  defp next_start([],move), do: move
  defp next_start(fallen,{x, dy}) do
    max_y = List.flatten(fallen) |> Enum.map(fn {_,y} -> y end) |> Enum.max()
    {x, max_y + dy + 1}
  end

  def crashed?(shape, fallen, bottom_y, [min_x, max_x]) do
    is_outside_area = (Enum.filter(shape, fn {x,y} -> y < bottom_y or x < min_x or x > max_x end) |> Enum.count()) > 0
    if is_outside_area do
      true
    else
      crashed_fallen?(shape, fallen)
    end
  end

  def crashed_fallen?(_, []), do: false
  def crashed_fallen?(shape, [fallen_piece | rest]) do
#    if is_higher?(shape, fallen_piece) do
#      false
#    else
      has_overlap?(shape, fallen_piece) or crashed_fallen?(shape, rest)
#    end
  end

  def has_overlap?([], _), do: false
  def has_overlap?([piece | rest], shape_b) do
    has_overlap = Enum.filter(shape_b, fn piece_b -> piece == piece_b end) |> Enum.count() > 0
    has_overlap or has_overlap?(rest, shape_b)
  end

  def is_higher?([], _), do: true
  def is_higher?(shape_a, shape_b) do
    lowest_a_y = shape_a |> Enum.map(fn {_,y} -> y end) |> Enum.min()
    highest_b_y = shape_b |> Enum.map(fn {_,y} -> y end) |> Enum.max()
    lowest_a_y > highest_b_y
#    is_higher = Enum.filter(shape_b, fn {_,by} -> y > by end) |> Enum.count() > 0
#    is_higher and is_higher?(rest, shape_b)
  end
end

[input] = SolutionDay16.load_input()
input = input |> List.to_tuple()
IO.inspect(input |> SolutionDay16.solve(2022))
#IO.inspect(input |> SolutionDay16.solve(1000000000000))
