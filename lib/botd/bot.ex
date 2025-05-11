defmodule Botd.Bot do
  @moduledoc """
  This module is responsible for handling the Telegram bot interactions.
  """

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

  # def update_chat(chats, action, chat_id, text) do
  #   # why
  #   chat = Map.get(chats, chat_id) || new_chat_state()

  #   next_chat =
  #     case action do
  #       :start ->
  #         %{
  #           chat
  #           | state: :waiting_for_name,
  #             name: nil,
  #             death_date: nil,
  #             reason: nil
  #         }

  #       :provide_name ->
  #         %{
  #           chat
  #           | state: :waiting_for_death_date,
  #             name: text
  #         }

  #       :provide_death_date ->
  #         %{
  #           chat
  #           | state: :waiting_for_reason,
  #             death_date: text
  #         }

  #       :provide_reason ->
  #         %{
  #           chat
  #           | state: :finished,
  #             reason: text
  #         }

  #       _ ->
  #         Logger.warning("Unknown action: #{inspect(action)}")
  #         chat
  #     end

  #   chats = Map.put(chats, chat_id, next_chat)
  #   chats
  # end

  def make_next_step(step) do
    case step do
      :waiting_for_start ->
        :waiting_for_name

      :waiting_for_name ->
        :waiting_for_death_date

      :waiting_for_death_date ->
        :waiting_for_reason

      :waiting_for_reason ->
        :finished

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

  defp process_message_from_user(key, update, chat, chat_id) do
    case chat.step do
      :waiting_for_start ->
        _text = get_in(update, ["message", "text"])
        # if /start ...
        next_step = make_next_step(:waiting_for_start)

        # side effect
        answer_on_message(key, chat_id, "Укажите имя")

        %{chat | step: next_step}

      :waiting_for_name ->
        name = get_in(update, ["message", "text"])
        next_step = make_next_step(:waiting_for_name)

        # side effect
        answer_on_message(key, chat_id, "Укажите дату смерти")

        %{chat | step: next_step, name: name}

      :waiting_for_death_date ->
        death_date = get_in(update, ["message", "text"])
        next_step = make_next_step(:waiting_for_death_date)

        # side effect
        answer_on_message(key, chat_id, "Укажите причину")

        %{chat | step: next_step, death_date: death_date}

      :waiting_for_reason ->
        reason = get_in(update, ["message", "text"])
        next_step = make_next_step(:waiting_for_reason)

        # side effect
        answer_on_message(key, chat_id, "проверьте данные")

        %{chat | step: next_step, reason: reason}

      :finished ->
        IO.inspect(chat)

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
