defmodule MarkevichMoney.Pipelines.Help.Callbacks do
  use MarkevichMoney.Constants
  alias MarkevichMoney.CallbackData
  alias MarkevichMoney.Pipelines.Help.Messages, as: HelpPipeline
  alias MarkevichMoney.Steps.Telegram.{SendMessage, SendPhoto}

  def call(
        %CallbackData{
          callback_data: %{"pipeline" => @help_callback, "type" => @help_callback_newby}
        } = callback_data
      ) do
    payload = callback_data |> Map.from_struct()

    message = """
    `> 🤔 Я новенький, помогите разобраться!`

    Отлично! Бот настроен и готов к работе!

    Теперь после каждого списания с карточки, подключенной к системе “Альфа-Клик”, в бот будет приходить уведомление о транзакции подобного вида.
    """

    payload
    |> Map.put(:output_message, message)
    |> SendMessage.call()

    payload
    |> Map.put(:output_file_id, get_file_id(:transaction_example))
    |> SendPhoto.call()

    message = """
    Бот старается сам определять категорию транзакции, но поначалу он может ошибиться или не указать категорию вовсе. Тут ему понадобится твоя помощь: нажми на кнопку `Категория` и самостоятельно выбери категорию, к которой относится твоя трата.

    В следующий раз бот уже будет знать, какую категорию ему выбрать. Помощь нужна боту только в самом начале работы: через несколько недель он начнёт автоматически присваивать категории всем твоим тратам, и выбирать категорию вручную нужно будет только изредка, в незнакомых для бота ситуациях.

    Если хочешь, чтобы бот не учитывал какую-то трату, то нажми кнопку `Удалить` под уведомлением о транзакции. *Само уведомление при этом удалять не надо!*

    Кнопки поменяются на `❌Удалить❌` и `Отмена`. Если точно хочешь удалить трату, жми на первую кнопку; если всё-таки передумаешь, то жми на вторую. После удаления транзакции на месте уведомления появится слово `Удалено`.

    Для того чтобы вызвать диалог помощи напиши /help

    В любой момент времени у бота можно запросить статистику по твоим тратам за определённый период времени. Подробнее об этом написано в разделе помощи `Как посмотреть статистику?`

    Бот может учесть даже траты, сделанные наличкой или другими карточками, если ты ему в этом немного поможешь. О том, как добавить транзакции вручную написано в разделе `Как добавить трату вручную?`

    Чувствуешь, что тратишь слишком много денег на что-то одно? Ты можешь установить лимит трат на определённую категорию, а бот будет периодически тебе о нём напоминать. Научиться выставлять лимиты можно при помощи раздела `Работа с лимитами.`


    Сейчас я специально вызову команду /help , для того, чтобы показать, как выглядит диалог помощи.
    """

    payload
    |> Map.put(:output_message, message)
    |> SendMessage.call()

    payload
    |> HelpPipeline.call()
  end

  def call(
        %CallbackData{
          callback_data: %{"pipeline" => @help_callback, "type" => @help_callback_add}
        } = callback_data
      ) do
    message = """
    Добавить транзакцию
    """

    callback_data
    |> Map.from_struct()
    |> Map.put(:output_message, message)
    |> SendMessage.call()
  end

  def call(
        %CallbackData{
          callback_data: %{"pipeline" => @help_callback, "type" => @help_callback_stats}
        } = callback_data
      ) do
    message = """
    Статистика
    """

    callback_data
    |> Map.from_struct()
    |> Map.put(:output_message, message)
    |> SendMessage.call()
  end

  def call(
        %CallbackData{
          callback_data: %{"pipeline" => @help_callback, "type" => @help_callback_limits}
        } = callback_data
      ) do
    message = """
    Лимиты
    """

    callback_data
    |> Map.from_struct()
    |> Map.put(:output_message, message)
    |> SendMessage.call()
  end

  def call(
        %CallbackData{
          callback_data: %{"pipeline" => @help_callback, "type" => @help_callback_support}
        } = callback_data
      ) do
    message = """
    Поддержка
    """

    callback_data
    |> Map.from_struct()
    |> Map.put(:output_message, message)
    |> SendMessage.call()
  end

  def call(
        %CallbackData{
          callback_data: %{"pipeline" => @help_callback, "type" => @help_callback_bug}
        } = callback_data
      ) do
    message = """
    Ошибка
    """

    callback_data
    |> Map.from_struct()
    |> Map.put(:output_message, message)
    |> SendMessage.call()
  end

  defp get_file_id(picture_name) do
    Application.get_env(:markevich_money, :tg_file_ids)[:help][:newby][picture_name]
  end
end
