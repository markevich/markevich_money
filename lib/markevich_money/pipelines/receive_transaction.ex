defmodule MarkevichMoney.Pipelines.ReceiveTransaction do
  alias MarkevichMoney.Steps.Telegram.{SendMessage}

  alias MarkevichMoney.Steps.Transaction.{
    CalculateAmountSign,
    FindOrCreateTransaction,
    FireTransactionCreatedEvent,
    ParseAccount,
    ParseAmount,
    ParseBalance,
    ParseCurrencyCode,
    ParseIssuedAt,
    ParseTo,
    PredictCategory,
    RenderTransaction,
    UpdateTransaction
  }

  def call(payload) do
    if valid?(payload[:input_message]) do
      payload
      |> Map.put(:parsed_attributes, %{})
      |> ParseAccount.call()
      |> ParseAmount.call()
      |> CalculateAmountSign.call()
      |> ParseCurrencyCode.call()
      |> ParseBalance.call()
      |> ParseTo.call()
      |> ParseIssuedAt.call()
      |> PredictCategory.call()
      |> FindOrCreateTransaction.call()
      |> UpdateTransaction.call()
      |> RenderTransaction.call()
      |> SendMessage.call()
      |> FireTransactionCreatedEvent.call()
    else
      payload
    end
  end

  def valid?(message) do
    message =~ "Успешно"
  end
end
