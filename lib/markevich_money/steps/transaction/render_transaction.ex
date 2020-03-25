defmodule MarkevichMoney.Steps.Transaction.RenderTransaction do
  use Timex
  alias MarkevichMoney.Transactions.Transaction

  def call(%{transaction: transaction} = payload) do
    payload
    |> Map.put(:output_message, render_table(transaction))
    |> insert_buttons()
  end

  defp render_table(%Transaction{} = transaction) do
    category = if transaction.transaction_category_id, do: transaction.transaction_category.name

    table =
      [
        ["Сумма", "#{transaction.amount} #{transaction.currency_code}"],
        ["Категория", category],
        ["Кому", transaction.to],
        ["Остаток", transaction.balance],
        # ["Счет", transaction.account],
        ["Дата", Timex.format!(transaction.issued_at, "{0D}.{0M}.{YY} {h24}:{0m}")]
      ]
      |> TableRex.Table.new()
      |> TableRex.Table.render!(horizontal_style: :off, vertical_style: :off)

    type =
      case Decimal.cmp(transaction.amount, 0) do
        :gt -> "Поступление"
        :lt -> "Списание"
        _ -> "Сомнительная"
      end

    """
    Транзакция №#{transaction.id}(#{type})
    ```

    #{table}
    ```
    """
  end

  defp insert_buttons(%{transaction: %{id: transaction_id}} = payload) do
    reply_markup = %Nadia.Model.InlineKeyboardMarkup{
      inline_keyboard: [
        [
          %Nadia.Model.InlineKeyboardButton{
            text: "Категория",
            callback_data: Jason.encode!(%{pipeline: "choose_category", id: transaction_id})
          },
          %Nadia.Model.InlineKeyboardButton{
            text: "❌ Удалить ❌",
            callback_data: Jason.encode!(%{pipeline: "delete_transaction", id: transaction_id})
          }
        ]
      ]
    }

    payload
    |> Map.put(:reply_markup, reply_markup)
  end
end
