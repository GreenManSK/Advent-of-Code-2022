defmodule Aoc do
  def day12 do
    input = SolutionDay12.load_input()
    solution1 = SolutionDay12.solve1(input)
    solution2 = SolutionDay12.solve2(input)
    {solution1, solution2}
  end
end
