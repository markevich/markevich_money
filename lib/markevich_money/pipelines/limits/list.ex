defmodule MarkevichMoney.Pipelines.Limits.List do
  alias MarkevichMoney.Gamifications
  alias MarkevichMoney.MessageData
  alias MarkevichMoney.Steps.Telegram.SendMessage

  def call(%MessageData{message: "/limits" <> _rest} = message_data) do
    message_data
    |> Map.from_struct()
    |> fetch_limits()
    |> render_message()
    |> SendMessage.call()
  end

  defp fetch_limits(%{current_user: user} = payload) do
    limits = Gamifications.list_categories_limits(user)

    Map.put(payload, :limits, limits)
  end

  defp render_message(%{limits: limits} = payload) do
    table = render_table(limits)

    message = """
    ```
    #{table}
    ```
    Для установки лимита используйте:

    */set_limit id value*
    """

    payload
    |> Map.put(:output_message, message)
  end

  defp render_table(limits) do
    limits
    |> Enum.map(fn category ->
      limit =
        case category.transaction_category_limit do
          nil -> "♾️"
          # credo:disable-for-next-line
          category_limit -> if category_limit.limit == 0, do: "♾️", else: category_limit.limit
        end

      [category.id, category.name, limit]
    end)
    |> TableRex.Table.new(["id", "Категория", "Лимит"], "Лимиты по категориям")
    |> TableRex.Table.put_column_meta(:all, align: :left, padding: 1)
    |> TableRex.Table.render!(horizontal_style: :off, vertical_style: :off)
  end
end