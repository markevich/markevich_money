defmodule MarkevichMoney.Gamification.Trackers.TransactionCategoryLimitTest do
  @moduledoc false
  use MarkevichMoney.DataCase, async: true
  use MecksUnit.Case
  use Oban.Testing, repo: MarkevichMoney.Repo
  import ExUnit.CaptureLog

  alias MarkevichMoney.Gamification.Trackers.TransactionCategoryLimit, as: LimitTracker

  describe "when transaction without transaction_category_id" do
    setup do
      %{transaction: insert(:transaction)}
    end

    test "skip execution", context do
      {:ok, result} =
        %{"transaction_id" => context.transaction.id}
        |> LimitTracker.perform(%{})

      refute(Map.has_key?(result, :output_message))
    end
  end

  describe "without category limit" do
    setup do
      category = insert(:transaction_category)
      transaction = insert(:transaction, transaction_category: category)

      %{transaction: transaction}
    end

    test "skip execution", context do
      {:ok, result} =
        %{"transaction_id" => context.transaction.id}
        |> LimitTracker.perform(%{})

      refute(Map.has_key?(result, :output_message))
    end
  end

  describe "when category limit is 0" do
    setup do
      user = insert(:user)
      category_limit = insert(:transaction_category_limit, user: user, limit: 0)

      transaction =
        insert(:transaction, user: user, transaction_category: category_limit.transaction_category)

      %{transaction: transaction}
    end

    test "skip execution", context do
      {:ok, result} =
        %{"transaction_id" => context.transaction.id}
        |> LimitTracker.perform(%{})

      refute(Map.has_key?(result, :output_message))
    end
  end

  describe "when category limit is 100 and new transaction does not exceeds total 50" do
    setup do
      user = insert(:user)
      category_limit = insert(:transaction_category_limit, user: user, limit: 100)

      transaction =
        insert(:transaction,
          user: user,
          amount: -5,
          transaction_category: category_limit.transaction_category
        )

      insert(:transaction,
        user: user,
        amount: -30,
        transaction_category: category_limit.transaction_category
      )

      %{transaction: transaction}
    end

    mocked_test "skip execution", context do
      {:ok, result} =
        %{"transaction_id" => context.transaction.id}
        |> LimitTracker.perform(%{})

      refute(Map.has_key?(result, :output_message))
    end
  end

  describe "when category limit is 100 and new transaction does not jump on current limit 50 <=> 70" do
    setup do
      user = insert(:user)
      category_limit = insert(:transaction_category_limit, user: user, limit: 100)

      transaction =
        insert(:transaction,
          user: user,
          amount: -5,
          transaction_category: category_limit.transaction_category
        )

      insert(:transaction,
        user: user,
        amount: -55,
        transaction_category: category_limit.transaction_category
      )

      %{transaction: transaction}
    end

    mocked_test "skip execution", context do
      {:ok, result} =
        %{"transaction_id" => context.transaction.id}
        |> LimitTracker.perform(%{})

      refute(Map.has_key?(result, :output_message))
    end
  end

  describe "when category limit is 100 and new transaction does exceeds total 50" do
    setup do
      user = insert(:user)
      category_limit = insert(:transaction_category_limit, user: user, limit: 100)
      category = category_limit.transaction_category
      transaction = insert(:transaction, user: user, amount: -25, transaction_category: category)
      insert(:transaction, user: user, amount: -30, transaction_category: category)

      %{
        user: user,
        transaction: transaction,
        category: category,
        category_limit: category_limit
      }
    end

    defmock Nadia do
      def send_message(_chat_id, _message, _opts) do
        {:ok, nil}
      end

      def edit_message_text(_chat_id, _message_id, _, _message_text, _options) do
        {:ok, nil}
      end

      def answer_callback_query(_callback_id, _options) do
        {:ok, nil}
      end
    end

    mocked_test "send warning message", context do
      {:ok, result} =
        %{"transaction_id" => context.transaction.id}
        |> LimitTracker.perform(%{})

      assert(Map.has_key?(result, :output_message))

      expected_message =
        "*Внимание! В категории \"#{context.category.name}\" потрачено 55.0% (55.0 BYN) из установленного лимита в #{
          context.category_limit.limit
        } BYN*\n"

      assert_called(
        Nadia.send_message(context.user.telegram_chat_id, expected_message, parse_mode: "Markdown")
      )
    end
  end

  describe "when category limit is 100 and new transaction does exceeds total 70" do
    setup do
      user = insert(:user)
      category_limit = insert(:transaction_category_limit, user: user, limit: 100)
      category = category_limit.transaction_category
      transaction = insert(:transaction, user: user, amount: -45, transaction_category: category)
      insert(:transaction, user: user, amount: -30, transaction_category: category)

      %{
        user: user,
        transaction: transaction,
        category: category,
        category_limit: category_limit
      }
    end

    defmock Nadia do
      def send_message(_chat_id, _message, _opts) do
        {:ok, nil}
      end

      def edit_message_text(_chat_id, _message_id, _, _message_text, _options) do
        {:ok, nil}
      end

      def answer_callback_query(_callback_id, _options) do
        {:ok, nil}
      end
    end

    mocked_test "send warning message", context do
      {:ok, result} =
        %{"transaction_id" => context.transaction.id}
        |> LimitTracker.perform(%{})

      assert(Map.has_key?(result, :output_message))

      expected_message =
        "*Внимание! В категории \"#{context.category.name}\" потрачено 75.0% (75.0 BYN) из установленного лимита в #{
          context.category_limit.limit
        } BYN*\n"

      assert(result[:output_message] == expected_message)
    end
  end

  describe "when category limit is 100 and new transaction jumps from 70% to > 100%" do
    setup do
      user = insert(:user)
      category_limit = insert(:transaction_category_limit, user: user, limit: 100)
      category = category_limit.transaction_category
      transaction = insert(:transaction, user: user, amount: -45, transaction_category: category)
      insert(:transaction, user: user, amount: -75, transaction_category: category)

      %{
        user: user,
        transaction: transaction,
        category: category,
        category_limit: category_limit
      }
    end

    defmock Nadia do
      def send_message(_chat_id, _message, _opts) do
        {:ok, nil}
      end

      def edit_message_text(_chat_id, _message_id, _, _message_text, _options) do
        {:ok, nil}
      end

      def answer_callback_query(_callback_id, _options) do
        {:ok, nil}
      end
    end

    mocked_test "send warning message", context do
      {:ok, result} =
        %{"transaction_id" => context.transaction.id}
        |> LimitTracker.perform(%{})

      assert(Map.has_key?(result, :output_message))

      expected_message =
        "*Внимание! В категории \"#{context.category.name}\" потрачено 120.0% (120.0 BYN) из установленного лимита в #{
          context.category_limit.limit
        } BYN*\n"

      assert(result[:output_message] == expected_message)
    end
  end

  describe "when category limit is 100 and new transaction jumps from 110% to > 120%" do
    setup do
      user = insert(:user)
      category_limit = insert(:transaction_category_limit, user: user, limit: 100)
      category = category_limit.transaction_category
      transaction = insert(:transaction, user: user, amount: -10, transaction_category: category)
      insert(:transaction, user: user, amount: -110, transaction_category: category)

      %{
        user: user,
        transaction: transaction,
        category: category,
        category_limit: category_limit
      }
    end

    defmock Nadia do
      def send_message(_chat_id, _message, _opts) do
        {:ok, nil}
      end

      def edit_message_text(_chat_id, _message_id, _, _message_text, _options) do
        {:ok, nil}
      end

      def answer_callback_query(_callback_id, _options) do
        {:ok, nil}
      end
    end

    mocked_test "send warning message", context do
      {:ok, result} =
        %{"transaction_id" => context.transaction.id}
        |> LimitTracker.perform(%{})

      assert(Map.has_key?(result, :output_message))

      expected_message =
        "*Внимание! В категории \"#{context.category.name}\" потрачено 120.0% (120.0 BYN) из установленного лимита в #{
          context.category_limit.limit
        } BYN*\n"

      assert(result[:output_message] == expected_message)
    end
  end

  describe "when payload is unknown" do
    defmock Sentry do
      def capture_message(_, _) do
      end
    end

    mocked_test "send message to sentry" do
      assert capture_log(fn ->
               LimitTracker.perform(%{"foo" => "bar"}, %{})

               assert_called(Sentry.capture_message(_, _))
             end) =~ "worker received unknown arguments"
    end
  end
end
