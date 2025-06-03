defmodule Botd.ChatBotAdapter do
  @moduledoc """
  Chat bot adapter for handling Telegram bot interactions.
  """

  @callback send_message(String.t()) :: {:ok, String.t()}
  @callback get_file_url(String.t(), String.t()) :: {:ok, String.t()}

  def send_message(key), do: impl().send_message(key)
  def get_file_url(key, file_id), do: impl().get_file_url(key, file_id)

  defp impl, do: Application.get_env(:botd, :telegram_chat, Botd.ExternalTelegramAPI)
end
