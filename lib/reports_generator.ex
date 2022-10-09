defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @available_foods [
    "açaí",
    "churrasco",
    "esfirra",
    "hambúrguer",
    "pastel",
    "pizza",
    "prato_feito",
    "sushi"
  ]

  @options [
    "foods",
    "users"
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), &sum_values/2)
  end

  def build_from_many(filenames) when not is_list(filenames),
    do: {:error, "Please provide a list of string"}

  def build_from_many(filenames) do
    report =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), &on_sum_reports/2)

    {:ok, report}
  end

  def fetch_higher_cost(report, option) when option in @options do
    {:ok, Enum.max_by(report[option], &get_value/1)}
  end

  def fetch_higher_cost(_report, _option), do: {:error, "Invalid option!"}

  defp on_sum_reports({:ok, result}, report), do: sum_reports(result, report)

  defp sum_reports(%{"foods" => foods1, "users" => users1}, %{
         "foods" => foods2,
         "users" => users2
       }) do
    foods = merge_maps(foods1, foods2)
    users = merge_maps(users1, users2)

    build_report(foods, users)
  end

  defp merge_maps(map1, map2),
    do: Map.merge(map1, map2, &sum_values_from_merge/3)

  defp sum_values_from_merge(_key, value1, value2), do: value1 + value2

  defp get_value({_key, value}), do: value

  defp sum_values([id, food_name, price], %{"foods" => foods, "users" => users}) do
    users = Map.put(users, id, users[id] + price)
    foods = Map.put(foods, food_name, foods[food_name] + 1)

    build_report(foods, users)
  end

  defp report_acc do
    foods = Enum.into(@available_foods, %{}, &{&1, 0})
    users = Enum.into(1..30, %{}, &{Integer.to_string(&1), 0})

    build_report(foods, users)
  end

  defp build_report(foods, users), do: %{"users" => users, "foods" => foods}
end
