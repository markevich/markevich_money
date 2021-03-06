defmodule MarkevichMoney.Pipelines.DeleteTransactionTest do
  @moduledoc false
  use MarkevichMoney.DataCase, async: true
  use MarkevichMoney.MockNadia, async: true
  use MecksUnit.Case
  use MarkevichMoney.Constants
  alias MarkevichMoney.CallbackData
  alias MarkevichMoney.Pipelines
  alias MarkevichMoney.Steps.Transaction.RenderTransaction
  alias MarkevichMoney.Transactions.Transaction

  describe "delete_transaction with 'dlt' action callback" do
    setup do
      user = insert(:user)
      transaction = insert(:transaction)

      message_id = 123
      callback_id = 234

      callback_data = %CallbackData{
        callback_data: %{
          "id" => transaction.id,
          "pipeline" => @delete_transaction_callback,
          "action" => @delete_transaction_callback_confirm
        },
        callback_id: callback_id,
        chat_id: user.telegram_chat_id,
        current_user: user,
        message_id: message_id,
        message_text: "doesn't matter"
      }

      {:ok,
       %{
         user: user,
         callback_data: callback_data,
         transaction: transaction,
         message_id: message_id,
         callback_id: callback_id
       }}
    end

    mocked_test "deletes the transaction", context do
      transaction = context.transaction
      Pipelines.call(context.callback_data)

      query = from t in Transaction, where: t.id == ^transaction.id
      refute(Repo.exists?(query))

      assert_called(
        Nadia.edit_message_text(
          context.user.telegram_chat_id,
          context.message_id,
          "",
          "Удалено",
          parse_mode: "Markdown"
        )
      )

      assert_called(Nadia.answer_callback_query(context.callback_id, text: "Success"))
    end
  end

  describe "delete_transaction with 'ask' action callback" do
    setup do
      user = insert(:user)
      transaction = insert(:transaction)

      message_id = 123
      callback_id = 234

      callback_data = %CallbackData{
        callback_data: %{
          "id" => transaction.id,
          "pipeline" => @delete_transaction_callback,
          "action" => @delete_transaction_callback_prompt
        },
        callback_id: callback_id,
        chat_id: user.telegram_chat_id,
        current_user: user,
        message_id: message_id,
        message_text: "doesn't matter"
      }

      {:ok,
       %{
         user: user,
         callback_data: callback_data,
         transaction: transaction,
         message_id: message_id,
         callback_id: callback_id
       }}
    end

    defmock MarkevichMoney.Steps.Transaction.RenderTransaction do
      def call(_) do
        :passthrough
      end
    end

    mocked_test "render confirmation buttons", context do
      reply_payload = Pipelines.call(context.callback_data)

      transaction = reply_payload[:transaction]
      assert(transaction.id == context.transaction.id)

      assert_called(RenderTransaction.call(_))
      assert(Map.has_key?(reply_payload, :output_message))

      assert(
        reply_payload[:reply_markup] == %Nadia.Model.InlineKeyboardMarkup{
          inline_keyboard: [
            [
              %Nadia.Model.InlineKeyboardButton{
                callback_data:
                  "{\"action\":\"#{@delete_transaction_callback_confirm}\",\"id\":#{context.transaction.id},\"pipeline\":\"#{@delete_transaction_callback}\"}",
                switch_inline_query: nil,
                text: "❌ Удалить ❌",
                url: nil
              },
              %Nadia.Model.InlineKeyboardButton{
                callback_data:
                  "{\"action\":\"#{@delete_transaction_callback_cancel}\",\"id\":#{context.transaction.id},\"pipeline\":\"#{@delete_transaction_callback}\"}",
                switch_inline_query: nil,
                text: "Отмена",
                url: nil
              }
            ]
          ]
        }
      )

      assert_called(
        Nadia.edit_message_text(
          context.user.telegram_chat_id,
          context.message_id,
          "",
          _,
          reply_markup: reply_payload[:reply_markup],
          parse_mode: "Markdown"
        )
      )

      assert_called(Nadia.answer_callback_query(context.callback_id, text: "Success"))
    end
  end

  describe "delete_transaction with 'cnl' action callback" do
    setup do
      user = insert(:user)
      transaction = insert(:transaction)

      message_id = 123
      callback_id = 234

      callback_data = %CallbackData{
        callback_data: %{
          "id" => transaction.id,
          "pipeline" => @delete_transaction_callback,
          "action" => @delete_transaction_callback_cancel
        },
        callback_id: callback_id,
        chat_id: user.telegram_chat_id,
        current_user: user,
        message_id: message_id,
        message_text: "doesn't matter"
      }

      {:ok,
       %{
         user: user,
         callback_data: callback_data,
         transaction: transaction,
         message_id: message_id,
         callback_id: callback_id
       }}
    end

    defmock MarkevichMoney.Steps.Transaction.RenderTransaction do
      def call(_) do
        :passthrough
      end
    end

    mocked_test "cancel deletion and render transaction", context do
      reply_payload = Pipelines.call(context.callback_data)

      transaction = reply_payload[:transaction]
      assert(transaction.id == context.transaction.id)

      assert_called(RenderTransaction.call(_))
      assert(Map.has_key?(reply_payload, :output_message))

      assert(
        reply_payload[:reply_markup] == %Nadia.Model.InlineKeyboardMarkup{
          inline_keyboard: [
            [
              %Nadia.Model.InlineKeyboardButton{
                callback_data:
                  "{\"id\":#{context.transaction.id},\"mode\":\"#{@choose_category_folder_short_mode}\",\"pipeline\":\"#{@choose_category_folder_callback}\"}",
                switch_inline_query: nil,
                text: "Категория",
                url: nil
              },
              %Nadia.Model.InlineKeyboardButton{
                callback_data:
                  "{\"action\":\"#{@delete_transaction_callback_prompt}\",\"id\":#{context.transaction.id},\"pipeline\":\"#{@delete_transaction_callback}\"}",
                switch_inline_query: nil,
                text: "Удалить",
                url: nil
              }
            ]
          ]
        }
      )

      assert_called(
        Nadia.edit_message_text(
          context.user.telegram_chat_id,
          context.message_id,
          "",
          _,
          reply_markup: reply_payload[:reply_markup],
          parse_mode: "Markdown"
        )
      )

      assert_called(Nadia.answer_callback_query(context.callback_id, text: "Success"))
    end
  end
end
