defmodule Botd.MockTelegramAPI do
  @moduledoc """
  Module for mocking Telegram bot external interactions.
  """

  def send_message(_key) do
    {:ok, "hello from Mock API"}
  end

  def get_file_url(key, file_id) do
    {:ok, "https://MOCK.api.telegram.org/file/bot#{key}/#{file_id}"}
  end
end
