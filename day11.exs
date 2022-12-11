defmodule SolutionDay11 do

  def load_input() do
    File.stream!("inputs/day11.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> Enum.chunk_every(7)
    |> Enum.map(&parse_monkey/1)
    |> List.to_tuple
  end

  def solve1(monkeys) do
    monkeys_count = tuple_size(monkeys)
    finished_monkeys = do_n_rounds(20, monkeys_count, monkeys)
    finished_monkeys
    |> Tuple.to_list()
    |> Enum.map(fn x -> x |> elem(6) end)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(2)
    |> Enum.reduce(fn x, acc -> x * acc end)
  end

  defp do_n_rounds(0, monkeys_count, monkeys), do: monkeys
  defp do_n_rounds(n, monkeys_count, monkeys) do
    new_monkeys = do_round(0, monkeys_count, monkeys)
    do_n_rounds(n - 1, monkeys_count, new_monkeys)
  end

  defp do_round(monkey_number, all_monkeys, monkeys) when monkey_number >= all_monkeys, do: monkeys
  defp do_round(monkey_number, all_monkeys, monkeys) do
    monkey = monkeys |> elem(monkey_number)
    {_, items, operation, test, true_monkey, false_monkey, inspected} = monkey

    new_monkeys = throw_items(items, operation, test, true_monkey, false_monkey, monkeys)

    updated_monkey = {monkey_number, [], operation, test,  true_monkey, false_monkey, inspected + length(items)}
    updated_monkeys = put_elem(new_monkeys, monkey_number, updated_monkey)
    do_round(monkey_number + 1, all_monkeys, put_elem(updated_monkeys, monkey_number, updated_monkey))
  end

  defp throw_items([], _, _, _, _, monkeys), do: monkeys
  defp throw_items([item | rest], operation, test, true_monkey, false_monkey, monkeys) do
    after_inspection = floor(run_operation(item, operation) / 3)
    new_monkey_number = if rem(after_inspection, test) == 0, do: true_monkey, else: false_monkey
    new_monkey = monkeys |> elem(new_monkey_number)

    new_monkey_items = new_monkey |> elem(1)
    new_monkey_items_updated = new_monkey_items ++ [after_inspection]
    new_monkey_updated = put_elem(new_monkey, 1, new_monkey_items_updated)

    new_monkeys = put_elem(monkeys, new_monkey_number, new_monkey_updated)
    throw_items(rest, operation, test, true_monkey, false_monkey, new_monkeys)
  end

  defp run_operation(item, {"+", a, b}), do: operation_member(item, a) + operation_member(item, b)
  defp run_operation(item, {"*", a, b}), do: operation_member(item, a) * operation_member(item, b)
  defp operation_member(item, "old"), do: item
  defp operation_member(_, number), do: number

  defp parse_monkey([monkey, items, operation, test, true_monkey, false_monkey | _]) do
    [_, number] = Regex.run(~r/Monkey (\d+):/, monkey)
    [_, string_items] = Regex.run(~r/Starting items: (.*)/, items)
    parsed_operation = parse_operation(operation)
    [_, test_number] = Regex.run(~r/Test: divisible by (\d+)/, test)
    [_, true_monkey_number] = Regex.run(~r/throw to monkey (\d+)/, true_monkey)
    [_, false_monkey_number] = Regex.run(~r/throw to monkey (\d+)/, false_monkey)
    {
      Integer.parse(number) |> elem(0),
      string_items |> String.split(", ", trim: true) |> Enum.map(fn x -> Integer.parse(x) |> elem(0)  end),
      parsed_operation,
      Integer.parse(test_number) |> elem(0),
      Integer.parse(true_monkey_number) |> elem(0),
      Integer.parse(false_monkey_number) |> elem(0),
      0
    }
  end

  defp parse_operation(operation) do
    [_, member1, operand, member2] = Regex.run(~r/Operation: new = (\w+) (.) (\w+)/, operation)
    {operand, parse_operation_member(member1), parse_operation_member(member2)}
  end
  defp parse_operation_member("old"), do: "old"
  defp parse_operation_member(number), do: Integer.parse(number) |> elem(0)
end

input = SolutionDay11.load_input()
SolutionDay11.solve1(input) |> IO.inspect(charlists: :as_lists)
