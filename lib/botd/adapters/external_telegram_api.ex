defmodule Botd.Adapters.ExternalTelegramAPI do
  @moduledoc """
  Module for handling Telegram bot external interactions.
  """

  def get_file_url(key, file_id) do
    case Telegram.Api.request(key, "getFile", %{file_id: file_id}) do
      {:ok, %{"file_path" => file_path}} ->
        {:ok, "https://api.telegram.org/file/bot#{key}/#{file_path}"}

      {:error, reason} ->
        {:error, reason}

      _ ->
        {:error, "Failed to get file URL. Unexpected response."}
    end
  end
end
