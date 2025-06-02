defmodule Botd.TelegramWTF do
  @moduledoc """
  Proxy module(?)
  """
  # @callback send_message(Botd.TelegramExternalApi.t()) :: {:ok, string()}
  @callback send_message(String.t()) :: {:ok, String.t()}

  def send_message(key), do: impl().send_message(key)

  defp impl, do: Application.get_env(:botd, :telegram_wtf, Botd.ExternalTelegramAPI)
end
