defmodule Botd.MockTelegramAPI do
  @moduledoc """
  Module for mocking Telegram bot external interactions.
  """

  def send_message(_key) do
    {:ok, "hello from Mock API"}
  end
end
