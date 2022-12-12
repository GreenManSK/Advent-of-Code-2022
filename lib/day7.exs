defmodule SolutionDay7 do
  @total_space 70000000
  @update_size 30000000

  def load_input() do
    File.stream!("inputs/day7.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, " ", trim: true)))
  end

  def solve1(tree) do
    get_all_dirs(tree) |> Enum.map(&get_size/1) |> Enum.filter(&(&1 < 100000)) |> Enum.sum()
  end

  def solve2(tree) do
    root_size = get_size(tree)
    free_space = @total_space - root_size
    need_to_delete = @update_size - free_space
    get_all_dirs(tree) |> Enum.map(&get_size/1) |> Enum.filter(&(&1 > need_to_delete)) |> Enum.min()
  end

  def create_tree([["$", "cd", "/"] | rest]) do
    root_dir = {"/",[],[]}
    create_tree(rest, [root_dir])
  end

  defp create_tree([["$", "ls"] | rest], [{path, _, dirs} | rest_path]) do
    {ls, rest} = Enum.split_while(rest, fn [start | _] -> start != "$" end)
    files = ls |> Enum.filter(fn [start | _] -> start != "dir" end) |> Enum.map(fn [size, path] -> {path, Integer.parse(size) |> elem(0)} end)
    create_tree(rest, [{path, files, dirs}] ++ rest_path)
  end

  defp create_tree([["$", "cd", ".."] | rest], [current, {parent, parent_files, parent_dirs} | rest_path]) do
    create_tree(rest, [{parent, parent_files, [current] ++ parent_dirs}] ++ rest_path)
  end

  defp create_tree([["$", "cd", new_dir] | rest], current) do
    create_tree(rest, [{new_dir, [], []}] ++ current)
  end
  defp create_tree([], [root_dir]) do
    root_dir
  end

  defp create_tree([], current) do
    create_tree([["$", "cd", ".."]], current)
  end

  defp get_size({dir, files, dirs}) do
    file_size = files |> Enum.map(fn {_, size} -> size end) |> Enum.sum()
    dir_size = dirs |> Enum.map(&get_size/1) |> Enum.sum()
    file_size + dir_size
  end

  defp get_all_dirs(path) do
    {_, _, sub_dirs} = path
    List.flatten([path] ++ (sub_dirs |> Enum.map(&get_all_dirs/1)))
  end
end

input = SolutionDay7.load_input()
tree = input |> Enum.to_list() |> SolutionDay7.create_tree()
IO.inspect(SolutionDay7.solve1(tree))
IO.inspect(SolutionDay7.solve2(tree))
