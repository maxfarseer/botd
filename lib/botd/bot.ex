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
          last_seen: -2
        }

        next_loop()

        {:ok, state}

      error ->
        Logger.error("Bot failed to self-identify: #{inspect(error)}")
        :error
    end
  end

  @impl GenServer
  def handle_info(:check, %{bot_key: key, last_seen: last_seen} = state) do
    state =
      key
      |> Telegram.Api.request("getUpdates", offset: last_seen + 1, timeout: 30)
      |> case do
        {:ok, []} ->
          state

        {:ok, updates} ->
          last_seen = handle_updates(updates, last_seen)
          %{state | last_seen: last_seen}
      end

    next_loop()
    {:noreply, state}
  end

  defp handle_updates(updates, last_seen) do
    updates
    |> Enum.map(fn update ->
      Logger.info("Update received: #{inspect(update)}")

      broadcast(update)

      update["update_id"]
    end)
    |> Enum.max(fn -> last_seen end)
  end

  defp broadcast(update) do
    Phoenix.PubSub.broadcast!(Botd.PubSub, "telegram_bot_update", {:update, update})
  end

  defp next_loop do
    Process.send_after(self(), :check, 0)
  end
end
