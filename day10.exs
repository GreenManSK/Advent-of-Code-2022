defmodule SolutionDay10 do
  @solution1_positions [20, 60, 100, 140, 180, 220]
  @ctr_width 40
  @ctr_height 6

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

  def solve2(input) do
    cycles = input |> Enum.map(&({&1, get_runtime(&1)})) |> run_instructions(1, [])
    grid = List.flatten(create_grid(@ctr_height, @ctr_width))
    IO.inspect(cycles)
    draw_grid(grid, cycles)
  end

  defp draw_grid([], _), do: nil
  defp draw_grid([{x, _} | rest_grid], [register | rest_cycles]) do
    IO.write(if is_in_range(register, x), do: "#", else: ".")
    if x == @ctr_width do
      IO.write("\n")
    end
    draw_grid(rest_grid, rest_cycles)
  end

  defp is_in_range(register, cycle_number) do
    register == cycle_number or register + 2 == cycle_number or register + 1 == cycle_number
  end

  defp create_grid(height, width) do
    Enum.map(1..height, fn y ->
      Enum.map(1..width, fn x -> {x, y} end)
    end)
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
IO.puts(input |> SolutionDay10.solve1())
input |> SolutionDay10.solve2()
