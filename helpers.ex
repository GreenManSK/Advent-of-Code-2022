defmodule Helpers do
  def transpose(m) do
    n = m |> Enum.filter(fn x -> not is_empty?(x) end)
    case n do
      [] -> []
      _ -> [Enum.map(n, &hd/1) | transpose(Enum.map(n, &tl/1))]
    end
  end

  def flip(m) do
    m |> Enum.map(&(Enum.reverse(&1)))
  end

  def is_empty?([]), do: true
  def is_empty?(_), do: false
end
