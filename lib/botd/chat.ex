defmodule Botd.Chat do
  @moduledoc """
  This module is responsible for handling the Telegram chat interactions.
  """

  alias Botd.Accounts
  alias Botd.Suggestions
  require Logger

  defstruct chat_id: nil,
            step: :waiting_for_start,
            name: nil,
            death_date: nil,
            reason: nil

  def init_state do
    %__MODULE__{}
  end

  defp make_next_step(:waiting_for_start), do: :selected_action
  defp make_next_step(:selected_add_person), do: :waiting_for_name
  defp make_next_step(:waiting_for_name), do: :waiting_for_death_date
  defp make_next_step(:waiting_for_death_date), do: :waiting_for_reason
  defp make_next_step(:waiting_for_reason), do: :finished

  def process_message_from_user(key, update, chat, chat_id) do
    case chat.step do
      :waiting_for_start -> handle_waiting_for_start(key, update, chat, chat_id)
      :selected_action -> handle_selected_action(key, update, chat, chat_id)
      :waiting_for_name -> handle_waiting_for_name(key, update, chat, chat_id)
      :waiting_for_death_date -> handle_waiting_for_death_date(key, update, chat, chat_id)
      :waiting_for_reason -> handle_waiting_for_reason(key, update, chat, chat_id)
      :finished -> handle_finished(key, update, chat, chat_id)
      _ -> handle_unknown_state(chat)
    end
  end

  defp handle_waiting_for_start(key, update, chat, chat_id) do
    text = get_in(update, ["message", "text"])

    if text == "/start" do
      Telegram.Api.request(key, "sendMessage",
        chat_id: chat_id,
        text: "Выберите действие",
        reply_markup: {:json, start_menu()}
      )

      next_step = make_next_step(:waiting_for_start)

      %__MODULE__{chat | step: next_step}
    else
      answer_on_message(key, chat_id, "Для начала работы введите /start")

      chat
    end
  end

  defp handle_selected_action(key, update, chat, chat_id) do
    text = get_in(update, ["message", "text"])

    if text == "Добавить" do
      answer_on_message(key, chat_id, "Укажите имя")
      next_step = make_next_step(:selected_add_person)
      %__MODULE__{chat | step: next_step}
    else
      answer_on_message(key, chat_id, "В данный момент доступно только добавление")
      chat
    end
  end

  defp handle_waiting_for_name(key, update, chat, chat_id) do
    name = get_in(update, ["message", "text"])
    next_step = make_next_step(:waiting_for_name)

    answer_on_message(key, chat_id, "Укажите дату смерти")

    %__MODULE__{chat | step: next_step, name: name}
  end

  defp handle_waiting_for_death_date(key, update, chat, chat_id) do
    death_date = get_in(update, ["message", "text"])
    {:ok, parsed_date} = Date.from_iso8601(death_date)
    next_step = make_next_step(:waiting_for_death_date)

    answer_on_message(key, chat_id, "Укажите причину")

    %__MODULE__{chat | step: next_step, death_date: parsed_date}
  end

  defp handle_waiting_for_reason(key, update, chat, chat_id) do
    reason = get_in(update, ["message", "text"])
    next_step = make_next_step(:waiting_for_reason)

    answer_on_message(key, chat_id, "Вы ввели данные:")

    updated_chat = %__MODULE__{chat | step: next_step, reason: reason}

    total =
      %{
        "Имя" => updated_chat.name,
        "Дата смерти" => updated_chat.death_date,
        "Причина" => updated_chat.reason
      }
      |> Enum.map_join("\n", fn {key, value} -> "#{key}: #{value}" end)

    answer_on_message(key, chat_id, total)

    Telegram.Api.request(key, "sendMessage",
      chat_id: chat_id,
      text: "Выберите действие",
      reply_markup: {:json, finished_menu()}
    )

    updated_chat
  end

  defp handle_finished(key, update, chat, chat_id) do
    text = get_in(update, ["message", "text"])

    case text do
      "Отправить" ->
        attributes = %{
          "name" => chat.name,
          "death_date" => chat.death_date,
          "cause_of_death" => chat.reason,
          "place" => "Hardcoded place"
        }

        user = Accounts.get_user_by_email("telegram@bot.com")

        case Suggestions.create_suggestion(attributes, user) do
          {:ok, _suggestion} ->
            answer_on_message(key, chat_id, "Данные успешно отправлены на модерацию!")

          {:error, changeset} ->
            Logger.error("Error creating suggestion: #{inspect(changeset)}")
            answer_on_message(key, chat_id, "Ошибка при отправке данных.")
        end

        chat

      "Внести новую запись в книгу" ->
        next_step = make_next_step(:waiting_for_start)
        %__MODULE__{chat | step: next_step}

      _ ->
        answer_on_message(key, chat_id, "Действие в разработке")
        chat
    end
  end

  defp handle_unknown_state(chat) do
    Logger.warning("Unknown chat state: #{inspect(chat)}")
    chat
  end

  defp answer_on_message(key, chat_id, text) do
    Telegram.Api.request(key, "sendMessage",
      chat_id: chat_id,
      text: text
    )
  end

  defp start_menu do
    keyboard = [
      ["Добавить"]
    ]

    keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}

    keyboard_markup
  end

  defp finished_menu do
    keyboard = [
      ["Отправить"],
      ["Редактировать", "Удалить"],
      ["Внести новую запись в книгу"]
    ]

    keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}

    keyboard_markup
  end
end
