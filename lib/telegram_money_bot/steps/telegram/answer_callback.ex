defmodule TelegramMoneyBot.Steps.Telegram.AnswerCallback do
  def call(%{callback_id: callback_id, output_message: _output_message} = payload) do
    Nadia.answer_callback_query(callback_id, text: "Success")

    payload
  end
end