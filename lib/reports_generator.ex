defmodule ReportsGenerator do
  def build(filename) do
    "reports/#{filename}"
    |> File.stream!()
    |> Enum.reduce(report_acc(), &on_convert_line_in_map/2)
  end

  defp on_convert_line_in_map(line, report),
    do:
      line
      |> parse_line()
      |> map_put(report)

  defp map_put([id, _food_name, price], report),
    do: Map.put(report, id, report[id] + price)

  defp parse_line(line),
    do:
      line
      |> String.trim()
      |> String.split(",")
      |> List.update_at(2, &String.to_integer/1)

  defp report_acc, do: Enum.into(1..30, %{}, &{Integer.to_string(&1), 0})
end
