defmodule Botd.ExternalTelegramAPI do
  @moduledoc """
  Module for handling Telegram bot external interactions.
  """

  def send_message(_key) do
    {:ok, "hello from Production API"}
  end
end
