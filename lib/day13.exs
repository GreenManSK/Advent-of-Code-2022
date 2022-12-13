defmodule SolutionDay13 do
  def load_input() do
    File.stream!("inputs/day13.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> Enum.chunk_every(3)
    |> Enum.map(&parse_pair/1)
  end

  defp parse_pair([a,b | _]) do
    {parse_packet(a), parse_packet(b)}
  end

  defp parse_packet(packet) do
    members = packet
    |> String.replace_prefix("[", "")
    |> String.replace_suffix("]", "")
    |> String.split(",", trim: true)
    {_, packet} = parse_members(members, [])
    packet
  end

  defp parse_members([], packet), do: {[], packet}
  defp parse_members([member | rest], packet) do
    cond do
      String.starts_with?(member, "[") -> parse_start(member, rest, packet)
      String.ends_with?(member, "]") -> parse_ending(member, rest, packet)
      true -> parse_members(rest, packet ++ [Integer.parse(member) |> elem(0)])
    end
  end

  defp parse_start(member, rest, packet) do
    member = String.replace_prefix(member, "[", "")
    new_rest = case member do
      "" -> rest
      _ -> [member | rest]
    end
    {new_members, sub_packet} = parse_members(new_rest, [])
    parse_members(new_members, packet ++ [sub_packet])
  end

  defp parse_ending(member, rest, packet) do
    [_, number, tail] = Regex.run(~r/^(\d*)(.*)\]$/, member)

    new_packet = case number do
      "" -> packet
      _ -> packet ++ [Integer.parse(number) |> elem(0)]
    end
    new_rest = case tail do
      "" -> rest
      _ -> [tail | rest]
    end
    {new_rest, new_packet}
  end

  def solve1(packets) do
    results = packets |> Enum.map(fn {a,b} -> are_in_order?(a,b) end)
    results_len = length(results)
    Enum.zip(1..results_len, results)
    |> Enum.filter(fn {_, valid} -> valid == true or valid == :same end)
    |> Enum.map(fn {n, _} -> n end)
    |> Enum.sum()
  end

  defp are_in_order?([], []), do: :same
  defp are_in_order?([], _), do: true
  defp are_in_order?(_, []), do: false
  defp are_in_order?([a | rest_a], [b | rest_b]) when is_number(a) and is_number(b) do
    cond do
      a == b -> are_in_order?(rest_a, rest_b)
      true -> a < b
    end
  end
  defp are_in_order?([a | rest_a], [b | rest_b]) when is_list(a) and is_list(b) do
    result = are_in_order?(a, b)
    case result do
      :same -> are_in_order?(rest_a, rest_b)
      _ -> result
    end
  end
  defp are_in_order?([a | rest_a], [b | rest_b]) when is_list(a) do
    result = are_in_order?(a, [b])
    case result do
      :same -> are_in_order?(rest_a, rest_b)
      _ -> result
    end
  end
  defp are_in_order?([a | rest_a], [b | rest_b]) when is_list(b) do
    result = are_in_order?([a], b)
    case result do
      :same -> are_in_order?(rest_a, rest_b)
      _ -> result
    end
  end
end

input = SolutionDay13.load_input()
IO.inspect(SolutionDay13.solve1(input), limit: :infinity)
