defmodule SolutionDay10 do
  @solution1_positions [20, 60, 100, 140, 180, 220]

  def load_input() do
    File.stream!("inputs/day10.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(String.split(&1, " ", trim: true)))
    |> Enum.to_list()
  end

  def solve1(input) do
    cycles = input |> Enum.map(&({&1, get_runtime(&1)})) |> run_instructions(1, [])
    @solution1_positions |> Enum.map(&(Enum.at(cycles, &1 - 1) * &1)) |> Enum.sum()
  end

  def run_instructions([], register, cycles), do: cycles ++ [register]
  def run_instructions([{inst, 1} | rest], register, cycles) do
    new_register = run_inst(register, inst)
    run_instructions(rest, new_register, cycles ++ [register])
  end
  def run_instructions([{inst, runtime} | rest], register, cycles) do
    run_instructions([{inst, runtime - 1} | rest], register, cycles ++ [register])
  end

  defp get_runtime(["addx" | _]), do: 2
  defp get_runtime(["noop" | _]), do: 1

  defp run_inst(register, ["noop" | _]), do: register
  defp run_inst(register, ["addx", value]) do
    {int_val, _} = Integer.parse(value)
    register + int_val
  end

end

input = SolutionDay10.load_input()
IO.inspect(input |> SolutionDay10.solve1(), limit: :infinity)
