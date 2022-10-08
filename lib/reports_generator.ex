defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), &sum_values/2)
  end

  def fetch_higher_cost(report), do: Enum.max_by(report, &get_value/1)

  defp get_value({_key, value}), do: value

  defp sum_values([id, _food_name, price], report),
    do: Map.put(report, id, report[id] + price)

  defp report_acc, do: Enum.into(1..30, %{}, &{Integer.to_string(&1), 0})
end
