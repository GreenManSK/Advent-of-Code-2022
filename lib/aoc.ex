defmodule Aoc do
  def day12 do
    input = SolutionDay12.load_input()
    solution1 = SolutionDay12.solve1(input)
    solution2 = SolutionDay12.solve2(input)
    {solution1, solution2}
  end

  def day16 do
    input = SolutionDay16.load_input()
    SolutionDay16.solve1(input)
  end
end
