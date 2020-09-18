defmodule TelegramMoneyBot.Pipelines.AddTransactionTest do
  @moduledoc false
  use TelegramMoneyBot.DataCase, async: true
  use TelegramMoneyBot.MockNadia, async: true
  use Oban.Testing, repo: TelegramMoneyBot.Repo
  use TelegramMoneyBot.Constants
  alias TelegramMoneyBot.MessageData
  alias TelegramMoneyBot.Pipelines
  alias TelegramMoneyBot.Transactions.Transaction

  describe "#{@add_message} message" do
    setup do
      user = insert(:user)
      to = "Something great"
      amount = 50.23
      category = insert(:transaction_category)

      # prediction
      insert(:transaction,
        user: user,
        to: to,
        amount: 10,
        transaction_category_id: category.id
      )

      %{user: user, category: category, to: to, amount: amount}
    end

    mocked_test "insert and renders transaction, fire event", context do
      #  FYI: /add 50.23 Something great
      reply_payload =
        Pipelines.call(%MessageData{
          message: "#{@add_message} #{context.amount} #{context.to}",
          chat_id: context.user.telegram_chat_id
        })

      transaction = reply_payload[:transaction]

      assert(%Transaction{} = transaction)
      assert(transaction.user_id == context.user.id)
      assert(transaction.amount == Decimal.from_float(-context.amount))
      assert(transaction.transaction_category_id == context.category.id)
      assert(transaction.to == context.to)
      assert(transaction.balance == Decimal.new(0))

      assert(Map.has_key?(reply_payload, :output_message))
      assert(Map.has_key?(reply_payload, :reply_markup))

      assert_called(Nadia.send_message(context.user.telegram_chat_id, _, _))

      assert_enqueued(
        worker: TelegramMoneyBot.Gamification.Events.Broadcaster,
        args: %{
          event: @transaction_created_event,
          transaction_id: transaction.id,
          user_id: context.user.id
        }
      )
    end
  end
end