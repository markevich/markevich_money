defmodule TelegramMoneyBot.PipelinesTest do
  @moduledoc false
  use TelegramMoneyBot.DataCase, async: true
  use TelegramMoneyBot.MockNadia, async: true
  alias TelegramMoneyBot.CallbackData
  alias TelegramMoneyBot.MessageData
  alias TelegramMoneyBot.Pipelines

  describe "unknown callback pipelines" do
    setup do
      user = insert(:user)
      message_id = 123
      callback_id = 234

      callback_data = %CallbackData{
        callback_data: %{"pipeline" => "_unknown"},
        callback_id: callback_id,
        chat_id: user.telegram_chat_id,
        current_user: user,
        message_id: message_id,
        message_text: ""
      }

      %{callback_data: callback_data}
    end

    test "does nothing", %{callback_data: callback_data} do
      result = Pipelines.call(callback_data)

      assert(result == callback_data)
    end
  end

  describe "message data with username" do
    setup do
      user = insert(:user)

      %{user: user}
    end

    test "puts current user into payload when user exists", %{user: user} do
      message_data = %MessageData{
        username: user.name,
        message: ""
      }

      result = Pipelines.call(message_data)

      assert(%{current_user: current_user} = result)
      assert(current_user == user)
    end

    test "does nothing when user is not exists" do
      message_data = %MessageData{
        username: "_PWNED",
        message: ""
      }

      result = Pipelines.call(message_data)

      assert(%{current_user: nil} = result)
    end
  end

  describe "message data with chat_id" do
    setup do
      user = insert(:user)

      %{user: user}
    end

    test "puts current user into payload when user exists", %{user: user} do
      message_data = %MessageData{
        chat_id: user.telegram_chat_id,
        message: ""
      }

      result = Pipelines.call(message_data)

      assert(%{current_user: current_user} = result)
      assert(current_user == user)
    end

    mocked_test "renders unauthorized message when user is not exists" do
      Pipelines.call(%MessageData{chat_id: -1, current_user: nil})

      assert_called(Nadia.send_message(-1, "Unauthorized", parse_mode: "Markdown"))
    end
  end

  describe "callback data with chat_id" do
    setup do
      user = insert(:user)

      %{user: user}
    end

    test "puts current user into payload when user exists", %{user: user} do
      callback_data = %CallbackData{
        chat_id: user.telegram_chat_id,
        callback_data: %{"pipeline" => "_unexisting"}
      }

      result = Pipelines.call(callback_data)

      assert(%{current_user: current_user} = result)
      assert(current_user == user)
    end
  end
end