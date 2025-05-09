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

  # chats is a finite state machine
  # chats = %{
  #   chat_id => %{
  #     state: :waiting_for_name,
  #     name: nil
  #   }
  # }
  defp handle_updates(key, updates, last_seen, _chats) do
    calc_last_seen =
      updates
      |> Enum.map(fn update ->
        Logger.info("Update received: #{inspect(update)}")

        chat_id = get_in(update, ["message", "chat", "id"])

        process_message_from_user(key, update, chat_id)

        broadcast(update)

        update["update_id"]
      end)
      |> Enum.max(fn -> last_seen end)

    new_state = %{
      last_seen: calc_last_seen,
      chats: %{}
    }

    new_state
  end

  defp new_chat_state do
    %{
      state: :waiting_for_name,
      name: nil,
      death_date: nil,
      reason: nil
    }
  end

  def update_chat(state, action, chat_id, text) do
    chat = Map.get(state.chats, chat_id) || new_chat_state()

    next_chat =
      case action do
        :start ->
          %{
            chat
            | state: :waiting_for_name,
              name: nil,
              death_date: nil,
              reason: nil
          }

        :provide_name ->
          %{
            chat
            | state: :waiting_for_death_date,
              name: text
          }

        :provide_death_date ->
          %{
            chat
            | state: :waiting_for_reason,
              death_date: text
          }

        :provide_reason ->
          %{
            chat
            | state: :finished,
              reason: text
          }

        _ ->
          Logger.warning("Unknown action: #{inspect(action)}")
          chat
      end

    chats = Map.put(state.chats, chat_id, next_chat)
    chats
  end

  def get_state!(state, chat_id) do
    Map.get(state.chats, chat_id)
  end

  defp broadcast(update) do
    Phoenix.PubSub.broadcast!(Botd.PubSub, "telegram_bot_update", {:update, update})
  end

  defp next_loop do
    Process.send_after(self(), :check, 0)
  end

  defp process_message_from_user(key, update, chat_id) do
    # state = get_state!(state, chat_id)

    case get_in(update, ["message", "text"]) do
      "/start" ->
        answer_on_message(key, chat_id, "Укажите имя персоны")

      "/stop" ->
        answer_on_message(key, chat_id, "Бот остановлен")

      _ ->
        answer_on_message(key, chat_id, "Unknown command")
    end
  end

  defp answer_on_message(key, chat_id, text) do
    Telegram.Api.request(key, "sendMessage",
      chat_id: chat_id,
      text: text
    )
  end
end
