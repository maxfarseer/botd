defmodule Botd.Bot do
  @moduledoc """
  This module is responsible for handling the Telegram bot interactions.
  """
  alias Botd.People

  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl GenServer
  def init(opts) do
    {key, _opts} = Keyword.pop!(opts, :bot_key)

    case Telegram.Api.request(key, "getMe") do
      {:ok, me} ->
        Logger.info("Bot successfully self-identified: #{me["username"]}")

        state = %{
          bot_key: key,
          me: me,
          last_seen: -2,
          chats: %{}
        }

        next_loop()

        {:ok, state}

      error ->
        Logger.error("Bot failed to self-identify: #{inspect(error)}")
        :error
    end
  end

  @impl GenServer
  def handle_info(
        :check,
        %{
          bot_key: key,
          last_seen: last_seen,
          chats: chats
        } = state
      ) do
    state =
      key
      |> Telegram.Api.request("getUpdates", offset: last_seen + 1, timeout: 30)
      |> case do
        {:ok, []} ->
          state

        {:ok, updates} ->
          new_state =
            handle_updates(
              key,
              updates,
              last_seen,
              chats
            )

          %{state | last_seen: new_state.last_seen, chats: new_state.chats}
      end

    next_loop()
    {:noreply, state}
  end

  defp handle_updates(key, updates, last_seen, chats) do
    calc_last_seen =
      updates
      |> Enum.map(fn update ->
        Logger.info("Update received: #{inspect(update)}")

        broadcast(update)

        update["update_id"]
      end)
      |> Enum.max(fn -> last_seen end)

    ##
    calc_new_chats = update_chats(key, updates, chats)

    new_state = %{
      last_seen: calc_last_seen,
      chats: calc_new_chats
    }

    new_state
  end

  def new_chat_state do
    %{
      chat_id: nil,
      step: :waiting_for_start,
      name: nil,
      death_date: nil,
      reason: nil
    }
  end

  # @steps %{
  #   :waiting_for_start => :waiting_for_name,
  #   :waiting_for_name => :waiting_for_death_date,
  #   :waiting_for_death_date => :waiting_for_reason,
  #   :waiting_for_reason => :finished,
  # }

  def make_next_step(step) do
    case step do
      :reset ->
        :waiting_for_start

      :waiting_for_start ->
        :selected_action

      :selected_add_person ->
        :waiting_for_name

      :waiting_for_name ->
        :waiting_for_death_date

      :waiting_for_death_date ->
        :waiting_for_reason

      :waiting_for_reason ->
        :finished

      :finished ->
        :after_finished

      _ ->
        Logger.warning("Unknown chat step: #{inspect(step)}")
        step
    end
  end

  def update_chats(key, updates, chats) do
    updates
    |> Enum.map(fn u ->
      chat_id = get_in(u, ["message", "chat", "id"])
      _text = get_in(u, ["message", "text"])
      chat = get_chat!(chats, chat_id)

      new_chat_state = process_message_from_user(key, u, chat, chat_id)

      %{new_chat_state | chat_id: chat_id}
    end)
    |> Enum.reduce(chats, fn chat, chats ->
      Map.put(chats, chat.chat_id, chat)
      # after new tests check if the same
      # Map.merge(chat, chats)
    end)
  end

  def get_chat!(chats, chat_id) do
    Map.get(chats, chat_id) || new_chat_state()
  end

  defp broadcast(update) do
    Phoenix.PubSub.broadcast!(Botd.PubSub, "telegram_bot_update", {:update, update})
  end

  defp next_loop do
    Process.send_after(self(), :check, 0)
  end

  def send_menu do
    keyboard = [
      ["Добавить"]
    ]

    keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}

    keyboard_markup
  end

  def finished_menu do
    keyboard = [
      ["Отправить"],
      ["Редактировать", "Удалить"],
      ["Внести новую запись в книгу"]
    ]

    keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}

    keyboard_markup
  end

  def process_message_from_user(key, update, chat, chat_id) do
    case chat.step do
      :waiting_for_start ->
        text = get_in(update, ["message", "text"])

        if text == "/start" do
          Telegram.Api.request(key, "sendMessage",
            chat_id: chat_id,
            text: "Выберите действие",
            reply_markup: {:json, send_menu()}
          )

          next_step = make_next_step(:waiting_for_start)

          %{chat | step: next_step}
        else
          answer_on_message(key, chat_id, "Для начала работы введите /start")

          chat
        end

      :selected_action ->
        text = get_in(update, ["message", "text"])

        if text == "Добавить" do
          answer_on_message(key, chat_id, "Укажите имя")
          next_step = make_next_step(:selected_add_person)
          %{chat | step: next_step}
        else
          answer_on_message(key, chat_id, "В данный момент доступно только добавление")
          chat
        end

      :waiting_for_name ->
        name = get_in(update, ["message", "text"])
        next_step = make_next_step(:waiting_for_name)

        answer_on_message(key, chat_id, "Укажите дату смерти")

        %{chat | step: next_step, name: name}

      :waiting_for_death_date ->
        death_date = get_in(update, ["message", "text"])
        {:ok, parsed_date} = Date.from_iso8601(death_date)
        next_step = make_next_step(:waiting_for_death_date)

        answer_on_message(key, chat_id, "Укажите причину")

        %{chat | step: next_step, death_date: parsed_date}

      :waiting_for_reason ->
        reason = get_in(update, ["message", "text"])
        next_step = make_next_step(:waiting_for_reason)

        answer_on_message(key, chat_id, "Вы ввели данные:")

        updated_chat = %{chat | step: next_step, reason: reason}

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

      :finished ->
        text = get_in(update, ["message", "text"])

        case text do
          "Отправить" ->
            # Extrahiere Attribute aus dem Chat-State
            attributes = %{
              name: chat.name,
              death_date: chat.death_date,
              cause_of_death: chat.reason
            }

            # Rufe die Funktion mit den Attributen auf
            case People.create_person(attributes) do
              {:ok, _person} ->
                answer_on_message(key, chat_id, "Данные успешно сохранены!")

              {:error, _changeset} ->
                answer_on_message(key, chat_id, "Ошибка при сохранении данных.")
            end

            chat

          "Внести новую запись в книгу" ->
            next_step = make_next_step(:reset)
            %{chat | step: next_step}

          _ ->
            answer_on_message(key, chat_id, "Действие в разработке")
            chat
        end

      _ ->
        Logger.warning("Unknown state: #{inspect(chat.step)}")
        chat
    end
  end

  defp answer_on_message(key, chat_id, text) do
    Telegram.Api.request(key, "sendMessage",
      chat_id: chat_id,
      text: text
    )
  end
end
