defmodule Botd.TelegramMessagesFixture do
  @moduledoc """
  This module defines test helpers for creating
  Telegram messages which are using in update struct for Botd.Chat.
  """

  def create_message_fixture(chat_id, date, message_id, text, update_id) do
    %{
      "message" => message(chat_id, date, message_id, text),
      "update_id" => update_id
    }
  end

  defp message(chat_id, date, message_id, text) do
    %{
      "chat" => chat(chat_id),
      "date" => date,
      "from" => from(chat_id),
      "message_id" => message_id,
      "text" => text
    }
  end

  defp chat(chat_id) do
    %{
      "first_name" => "John",
      "id" => chat_id,
      "last_name" => "Doe",
      "type" => "private",
      "username" => "johndoe"
    }
  end

  defp from(chat_id) do
    %{
      "first_name" => "John",
      "id" => chat_id,
      "is_bot" => false,
      "is_premium" => true,
      "language_code" => "en",
      "last_name" => "Doe",
      "username" => "johndoe"
    }
  end

  def text_message_v2_1_0 do
    %{
      "message" => %{
        "chat" => %{
          "first_name" => "John",
          "id" => 1,
          "last_name" => "Doe",
          "type" => "private",
          "username" => "johndoe"
        },
        "date" => 1_748_714_354,
        "from" => %{
          "first_name" => "John",
          "id" => 1,
          "is_bot" => false,
          "is_premium" => true,
          "language_code" => "en",
          "last_name" => "Doe",
          "username" => "johndoe"
        },
        "message_id" => 1347,
        "text" => "Some text message"
      },
      "update_id" => 597_970_970
    }
  end
end
