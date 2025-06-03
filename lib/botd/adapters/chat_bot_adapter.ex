defmodule Botd.Adapters.ChatBotAdapter do
  @moduledoc """
  Chat bot adapter for handling Telegram bot interactions.
  """

  @callback get_file_url(String.t(), String.t()) :: {:ok, String.t()}

  def get_file_url(key, file_id), do: impl().get_file_url(key, file_id)

  defp impl, do: Application.get_env(:botd, :telegram_chat, Botd.Adapters.ExternalTelegramAPI)
end
