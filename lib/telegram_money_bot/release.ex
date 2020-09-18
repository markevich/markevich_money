defmodule TelegramMoneyBot.Release do
  alias TelegramMoneyBot.Steps.Telegram.SendMessage
  alias TelegramMoneyBot.Users

  @version Mix.Project.config()[:version]
  def send_changelog! do
    @version
    |> changelog()
    |> send_to_all_users()
  end

  # Новое
  # Изменено
  # Удалено
  # Исправления
  # Безопасность и быстродействие:

  def changelog("0.4.1") do
    """
    *🤍❤️🤍 Обновление `0.4.0` => `0.4.1`*

    *18 Сентября 2020*

    Исправлено:
      *- Статистика трат по лимитам: убрана отрисовка категорий с лимитом = 0.*

    Безопасность и быстродействие:
      *- Обновлены все используемые фреймворки и библиотеки.*
    """
  end

  def changelog("0.4.0") do
    """
    *🤍❤️🤍 Обновление `0.3.12` => `0.4.0`*

    *10 Сентября 2020*

    Новое:
      *- Добавлена кнопка "Просмотр расходов по лимитам" в статистика /stats *
      *- Добавлено отображение расходов по лимитам в команде /limits *

    Исправления:
      *- Убрана кнопка "Детализированная статистика" для статистики за все время.*
      *- Внутренняя оптимизация. Бот стал быстрее, выше и сильнее.*
      *- Безопасность превыше всего. Все компоненты обновлены до последних версий.*


    Все запланированные задачи для этапа `0.3` => `0.4` выполнены!

    Следующая запланированная большая версия - `1.0`. С ее реализацией закончится период бета тестирования бота.

    Главные задачи этапа `0.4` => `1.0`:
      *- Автоматическая регистрация для новых пользователей.*
      *- Интерактивная обучалка для новых пользователей.*
      *- Переосмысление и переработка всех диалогов помощи.*

    Спасибо что остаетесь с ботом, дальше будет еще круче!

    Жыве Беларусь! 🤍❤️🤍
    """
  end

  def changelog("0.3.12") do
    """
    *🤍❤️🤍 Релиз версии `0.3.12`*

    *22 Августа 2020*

    Изменено:
      *- Улучшен алгоритм "угадывания" категории в транзакции. Бот стал приоритизировать ваше мнение, а не большинства.*
    """
  end

  def changelog("0.3.11") do
    """
    *🤍❤️🤍 Релиз версии `0.3.11`*

    *22 Августа 2020*

    Технический релиз:
      *- обновлены все используемые фреймворки и библиотеки*
    """
  end

  def changelog("0.3.10") do
    """
    *Релиз версии `0.3.10` 🚢*

    *24 Июля 2020*

    Технический релиз:
      *- обновлены все используемые фреймворки и библиотеки*
    """
  end

  def changelog("0.3.9") do
    """
    *Релиз версии `0.3.9` 🚢*

    *30 Июня 2020*

    Технический релиз:
      *- обновлены все используемые фреймворки и библиотеки*
    """
  end

  def changelog("0.3.8") do
    """
    *Релиз версии `0.3.8` 🚢*

    *1 Июня 2020*

    Добавлено:
      *- новая категория "📚 Образование"*
    """
  end

  def changelog("0.3.7") do
    """
    *Релиз версии `0.3.7` 🚢*

    *27 Мая 2020*

    Технический релиз:
      *- обновлены все используемые фреймворки и библиотеки*
    """
  end

  def changelog("0.3.6") do
    """
    *Релиз версии `0.3.6` 🚢*

    *24 Мая 2020*

    Технический релиз:
      *- шаг назад, два вперед. Все (почти :D) внутренние модули переписанны для упрощения их автоматического тестирования. А это значит что новый функционал будет появляться значительно чаще!*

    *Исправлено:*
      *- команда /add научилась распознавать траты состоящие из нескольких слов, например* `/add 10 Фантастическая курочка` *создаст транзакцию на* `10`* рублей и* `"Фантастическая курочка"`* в строке* `"кому"`
    """
  end

  def changelog("0.3.5") do
    """
    *Релиз версии `0.3.5` 🚢*

    *13 Апреля 2020*

    *Изменено:*
      *- категория "Путешествия" переименована в "Туризм".*

    *Исправлено:*
      *- зафиксирована сортировка категорий. Порядок отображаемых категорий больше не будет зависеть от фазы луны и других неизвестных природных явлений.*
    """
  end

  def changelog("0.3.4") do
    """
    *Релиз версии `0.3.4` 🚢*

    *6 Апреля 2020*

    *Добавлено:*
      *- отображение транзакций без категории в статистике /stats*
    """
  end

  def changelog("0.3.3") do
    """
    *Релиз версии `0.3.3` 🚢*

    *4 Апреля 2020*

    *Изменено:*
      *- Категория "Мама" переименована в "Семья".*
    """
  end

  def changelog("0.3.2") do
    """
    *Релиз версии `0.3.2` 🚢*

    *4 Апреля 2020*

    *Изменено:*
      *- Обновлено сообщение о достижении порога бюджета*
    """
  end

  def changelog("0.3.1") do
    """
    *Релиз версии `0.3.1` 🚢*

    *4 Апреля 2020*

    *Изменено:*
      *- При достижении лимита больше чем на 100% сообщение о лишних тратах будет показываться на каждую новую транзакцию.*
    """
  end

  def changelog("0.3.0") do
    """
    *Релиз версии `0.3.0` 🚢*

    *3 Апреля 2020*

    Релиз включает себя новый модуль геймофикации, с помощью которого бот наконец начнет выполнять одну из первостепенных задач - мотивировать вас *экономить* деньги.

    Фокусом ближайших релизов будет работа с планированием трат на текущий месяц - бюджетом. Создание такого плана позволит вам заранее определить, будет ли у вас достаточно денег на все ваши потребности и хотелки. Так же бюджет позволит более точно прогнозировать количество денег которые вы сможете отложить на будущее.

    *Добавлено:*
      *- Добавлен новый гибкий модуль геймофикации, на основе которого будут строиться всякие клевые штуки.*
      *- Бот теперь мотивирует вас следить за вашим бюджетом. При установленном лимите на категорию вам придет предупреждение о приближении к порогу в 50%, 70%, 90% и 100% от бюджета*
    """
  end

  def changelog("0.2.4") do
    """
    *Релиз версии `0.2.4` 🚢*

    *30 Марта 2020*

    *Исправлено:*
      *- Исправлена ошибка с пропавшими категориями в команде /limits.*
    """
  end

  def changelog("0.2.3") do
    """
    *Релиз версии `0.2.3` 🚢*

    *29 Марта 2020*

    *Добавлено:*
      *- /limits - Новая команда которая позволяет просмотреть список лимитов по всем категориям*
      *- /set_limit - Новая команда которая позволяет установить лимит на траты по категории*


    *Изменено*
      *- Обновлен текст /help команды.*
    """
  end

  def changelog("0.2.2") do
    """
    *Релиз версии `0.2.2` 🚢*

    *26 Марта 2020*

    *Добавлено:*
      *- Отныне бот будет удалять ваши транзакции только после повторного подтверждения.* [#30](https://github.com/markevich/telegram_money_bot/issues/30)

    *Изменено*
      *- Изменен текст /help команды.*
      *- Трудяга трудился и переписал все юнит тесты. * [#32](https://github.com/markevich/telegram_money_bot/issues/32)

    *Удалено*
      *- '/start' команды больше нет.*
    """
  end

  def changelog("0.2.1") do
    """
    *Version `0.2.1` shipped 🚢*

    *Released on March 24 2020*

    *Changed*
      *- "Выбрать категорию" renamed to "Категория".*
      *- Pushing any "stats" button will send new message instead of updating the original one* [#29](https://github.com/markevich/telegram_money_bot/issues/29)
    """
  end

  def changelog("0.2.0") do
    """
    *Version `0.2.0` shipped 🚢*

    *Released on March 19 2020*

    *Added*
      *- Transactions can be deleted using telegram bot.*

    *Removed*
      *- "Ignore" category disappeared in favor of new `Delete` feature.*
    """
  end

  def changelog("0.1.7") do
    """
    🔥🔥🔥🔥🔥🔥

    MoneyBot updated to version `0.1.7` 🍾🍾

      Fixes:
        - Fixed zero amount transactions weren't rendered.
        - Stats pipeline optimized. [GH#12](https://github.com/markevich/telegram_money_bot/issues/12)
    """
  end

  def changelog("0.1.6") do
    """
    🔥🔥🔥🔥🔥🔥

    MoneyBot updated to version `0.1.6` 🍾🍾

      Fixes:
        - Bot won't parse unsuccessful transactions anymore. [GH#17](https://github.com/markevich/telegram_money_bot/issues/17)
    """
  end

  def changelog("0.1.5") do
    """
    🛠️🛠️🛠️🛠️🛠️🛠️🛠️🛠️

    MoneyBot updated to version `0.1.5` 🍾🍾

      New:
        - Rename some database columns. [GH#3](https://github.com/markevich/telegram_money_bot/issues/3) [GH#4](https://github.com/markevich/telegram_money_bot/issues/4)
        - Add not null constraints to some critical columns. [GH#6](https://github.com/markevich/telegram_money_bot/issues/3) [GH#4](https://github.com/markevich/telegram_money_bot/issues/6)
    """
  end

  def changelog("0.1.4") do
    """
    🔥🔥🔥🔥🔥🔥🔥

    MoneyBot updated to version `0.1.4` 🍾🍾

      New:
        - Elixir and Javascript packages updated to latest versions. [GH#18](https://github.com/markevich/telegram_money_bot/issues/18)
    """
  end

  def changelog("0.1.3") do
    """
    🔥🔥🔥🔥🔥🔥🔥

    MoneyBot updated to version `0.1.3` 🍾🍾

      New:
        - Added integration with https://sentry.io. Errors shall not pass!! [GH#15](https://github.com/markevich/telegram_money_bot/issues/15)
    """
  end

  def changelog("0.1.2") do
    """
    🔥🔥🔥🔥🔥🔥🔥

    MoneyBot updated to version `0.1.2` 🍾🍾

      Fixes:
        - Reduce padding for category statistics table
    """
  end

  def changelog("0.1.1") do
    """
    MoneyBot updated to version `0.1.1` 🍾🍾

      New:
        - Implement statistic by categories. Click /stats to explore. [GH#10](https://github.com/markevich/telegram_money_bot/issues/10)
        - Implement automated release log sender. [GH#13](https://github.com/markevich/telegram_money_bot/issues/13)

      Fixes:
        - Fixed float numbers rounding. There should be no numbers like `1.4e3` anymore
    """
  end

  def old do
    message = """
    ```
    New bot version released! Changes:

    - Fix datetime parsing for values without time
    - Add remaining tests. Coverage is 100\% now
    - Add test coverage for creating a transaction from manual input
    - Exclude unrelevant files from coverage calculation
    - Add test coverage for /add command
    - Add emoji to categories
    - Apply mix formatter
    - Add test coverage for /start message
    - Add test coverage to /help pipeline
    - Add test coverage for setting the current user in callbacks
    - Add test coverage for set_category pipeline
    - Add test coverage for stats callbacks pipeline
    - Add test coverage for choose_category pipeline
    - Add tests for mailgun receiver
    - Fix account regexp
    - Update elixir packages
    - Update npm packages
    ```
    """

    SendMessage.call(%{
      output_message: message,
      chat_id: 133_501_152
    })
  end

  defp send_to_all_users(message) do
    Users.all_users()
    |> Enum.each(fn user ->
      SendMessage.call(%{
        output_message: message,
        chat_id: user.telegram_chat_id
      })
    end)
  end
end