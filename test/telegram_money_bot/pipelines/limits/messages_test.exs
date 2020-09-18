defmodule TelegramMoneyBot.Pipelines.Limits.MessagesTest do
  @moduledoc false
  use TelegramMoneyBot.DataCase, async: true
  use TelegramMoneyBot.MockNadia, async: true
  use TelegramMoneyBot.Constants
  alias TelegramMoneyBot.Gamification.TransactionCategoryLimit
  alias TelegramMoneyBot.MessageData
  alias TelegramMoneyBot.Pipelines
  alias TelegramMoneyBot.Steps.Limits.RenderLimitsValues, as: Render

  describe "#{@limits_message} message" do
    setup do
      user = insert(:user)
      unrelated_user = insert(:user)
      category_without_limit = insert(:transaction_category, id: -3, name: "limit_cat1")
      category_with_limit = insert(:transaction_category, id: -2, name: "limit_cat2")
      category_with_0_limit = insert(:transaction_category, id: -1, name: "limit_cat3")

      insert(:transaction_category_limit,
        transaction_category: category_with_limit,
        user: user,
        limit: 125
      )

      insert(:transaction_category_limit,
        transaction_category: category_with_0_limit,
        user: user,
        limit: 0
      )

      insert(:transaction_category_limit,
        transaction_category: category_with_limit,
        user: unrelated_user,
        limit: 0
      )

      %{
        user: user,
        category_without_limit: category_without_limit,
        category_with_limit: category_with_limit,
        category_with_0_limit: category_with_0_limit
      }
    end

    defmock TelegramMoneyBot.Steps.Limits.RenderLimitsValues do
      def call(_) do
        :passthrough
      end
    end

    mocked_test "Renders limits message", context do
      reply_payload =
        Pipelines.call(%MessageData{message: @limits_message, current_user: context.user})

      assert_called(Render.call(_))
      assert(Map.has_key?(reply_payload, :output_message))

      assert(Map.has_key?(reply_payload, :limits))
      assert(Enum.count(reply_payload[:limits]) == 3)

      assert_called(
        Nadia.send_message(
          context.user.telegram_chat_id,
          _,
          parse_mode: "Markdown"
        )
      )
    end
  end

  describe "#{@set_limit_message} message" do
    setup do
      user = insert(:user)
      category = insert(:transaction_category)
      new_limit = 100

      %{
        user: user,
        category: category,
        new_limit: new_limit
      }
    end

    mocked_test "Sets the limit with correct message", context do
      message = "#{@set_limit_message} #{context.category.id} #{context.new_limit}"
      Pipelines.call(%MessageData{message: message, current_user: context.user})

      query =
        from(l in TransactionCategoryLimit,
          where:
            l.user_id == ^context.user.id and
              l.transaction_category_id == ^context.category.id and
              l.limit == ^context.new_limit
        )

      assert(Repo.exists?(query))

      expected_message = """
      Упешно!

      Нажмите на #{@limits_message} для просмотра обновленных лимитов
      """

      assert_called(
        Nadia.send_message(
          context.user.telegram_chat_id,
          expected_message,
          parse_mode: "Markdown"
        )
      )
    end

    mocked_test "Returns support message if input message is invalid", context do
      message = "#{@set_limit_message} blabla blabla"
      Pipelines.call(%MessageData{message: message, current_user: context.user})

      expected_message = """
      Я не смог распознать эту команду

      Пример правильной команды:
      *#{@set_limit_message} 1 150*
        - *1* это *id* категории, которую можно подсмотреть с помощью команды #{@limits_message}
        - *150* это целочисленное значение лимита
      """

      assert_called(
        Nadia.send_message(
          context.user.telegram_chat_id,
          expected_message,
          parse_mode: "Markdown"
        )
      )
    end
  end
end