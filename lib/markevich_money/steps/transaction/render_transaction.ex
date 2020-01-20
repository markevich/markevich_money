defmodule MarkevichMoney.Steps.Transaction.RenderTransaction do
  use Timex

  def call(%{transaction: transaction} = payload) do
    payload
    |> Map.put(:output_message, render_table(transaction))
    |> insert_buttons()
  end

  defp render_table(transaction) do
    category = if transaction.transaction_category, do: transaction.transaction_category.name

    table =
      [
        ["Сумма", "#{transaction.amount} #{transaction.currency_code}"],
        ["Категория", category],
        ["Кому", transaction.target],
        ["Остаток", transaction.balance],
        # ["Счет", transaction.account],
        ["Дата", Timex.format!(transaction.datetime, "{0D}.{0M}.{YY} {h24}:{0m}")]
      ]
      |> TableRex.Table.new()
      |> TableRex.Table.render!(horizontal_style: :off, vertical_style: :off)

    type =
      case transaction.type do
        "income" -> "Поступление"
        "outcome" -> "Списание"
        true -> "Неизвестно"
      end

    """
    Транзакция №#{transaction.id}(#{type})
    ```

    #{table}
    ```
    """
  end

  defp insert_buttons(%{transaction: %{id: transaction_id}} = payload) do
    callback_data = Jason.encode!(%{pipeline: "choose_category", id: transaction_id})

    reply_markup = %Nadia.Model.InlineKeyboardMarkup{
      inline_keyboard: [
        [
          %Nadia.Model.InlineKeyboardButton{
            text: "Выбрать категорию",
            callback_data: callback_data
          }
        ]
      ]
    }

    payload
    |> Map.put(:reply_markup, reply_markup)
  end
end
