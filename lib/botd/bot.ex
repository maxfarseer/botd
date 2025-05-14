defmodule Botd.Bot do
  @moduledoc """
  This module is responsible for handling the Telegram bot interactions.
  """

  alias Botd.Chat

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

  def update_chats(key, updates, chats) do
    Enum.reduce(updates, chats, fn update, acc ->
      chat_id = get_in(update, ["message", "chat", "id"])
      chat = Map.get(acc, chat_id, Chat.init_state())

      new_chat_state = Chat.process_message_from_user(key, update, chat, chat_id)
      Map.put(acc, chat_id, %Chat{new_chat_state | chat_id: chat_id})
    end)
  end

  def get_chat!(chats, chat_id) do
    Map.get(chats, chat_id) || Chat.init_state()
  end

  defp broadcast(update) do
    Phoenix.PubSub.broadcast!(Botd.PubSub, "telegram_bot_update", {:update, update})
  end

  defp next_loop do
    Process.send_after(self(), :check, 0)
  end
end
