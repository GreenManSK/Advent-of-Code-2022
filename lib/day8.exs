defmodule SolutionDay8 do
  def load_input() do
    File.stream!("inputs/day8.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, "", trim: true)))
    |> Enum.to_list()
  end

  def solve1(input) do
    visibles = create_result_map(input, false)
    result = run_from_all_sides(input, visibles, &check_row/3)
    count_visible(result)
  end

  def solve2(input) do
    scores = create_result_map(input, 1)
    result = run_from_all_sides(input, scores, &find_score/3)
    result
    find_max_score(result)
  end

  def run_from_all_sides(input, results, result_fn) do
    results = check_by_rows(input, results, result_fn)

    flip_input = Helpers.flip(input)
    results = check_by_rows(flip_input, Helpers.flip(results),result_fn)

    transpose_input = Helpers.transpose(flip_input)
    transpose_results = Helpers.transpose(results)
    transpose_results = check_by_rows(transpose_input, transpose_results, result_fn)

    transpose_results = check_by_rows(Helpers.flip(transpose_input), Helpers.flip(transpose_results), result_fn)
    transpose_results
  end

  defp check_by_rows([], results, _), do: results
  defp check_by_rows([input_row | input_rest], [results_row | results_rest], result_fn) do
    new_results_row = result_fn.(input_row, results_row, -1)
    [new_results_row] ++ check_by_rows(input_rest, results_rest, result_fn)
  end

  defp check_row([], [], _), do: []
  defp check_row([current | rest], [is_already_visible | visible_rest], max) do
    is_visible = is_already_visible or current > max
    new_max = if current > max, do: current, else: max
    [is_visible] ++ check_row(rest, visible_rest, new_max)
  end

  defp find_score([], [], _), do: []
  defp find_score([current | rest], [current_score | scores_rest], _) do
    visible_from = case rest do
      [] -> 0
      _ ->
        lowers = Enum.take_while(rest, fn x -> x < current end) |> Enum.count()
        alls = rest |> Enum.count()
        if alls == lowers, do: lowers, else: lowers + 1
    end
    [current_score * visible_from] ++ find_score(rest, scores_rest,0)
  end

  defp create_result_map(input, default_value) do
    input |> Enum.map(&(Enum.map(&1, fn _ -> default_value end)))
  end

  defp count_visible(visibles) do
    List.flatten(visibles) |> Enum.filter(&(&1)) |> Enum.count()
  end

  defp find_max_score(result) do
    List.flatten(result) |> Enum.max()
  end
end

input = SolutionDay8.load_input()
IO.inspect(input |> SolutionDay8.solve1())
IO.inspect(input |> SolutionDay8.solve2())
