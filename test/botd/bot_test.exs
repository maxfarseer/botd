defmodule Botd.BotTest do
  use Botd.DataCase, async: true
  alias Botd.Bot

  describe "process_message_from_user/4" do
    setup do
      key = "dummy_key"
      chat_id = 12_345
      {:ok, key: key, chat_id: chat_id}
    end

    test "handles :waiting_for_start step", %{key: key, chat_id: chat_id} do
      chat = %{step: :waiting_for_start}
      update = %{"message" => %{"text" => "/start"}}

      result = Bot.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :selected_action
    end

    test "handles action", %{key: key, chat_id: chat_id} do
      chat = %{step: :selected_action}
      update = %{"message" => %{"text" => "Добавить"}}

      result = Bot.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :waiting_for_name
    end

    test "handles :waiting_for_name step", %{key: key, chat_id: chat_id} do
      chat = %{step: :waiting_for_name, name: nil}
      update = %{"message" => %{"text" => "John Doe"}}

      result = Bot.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :waiting_for_death_date
      assert result.name == "John Doe"
    end

    test "handles :waiting_for_death_date step", %{key: key, chat_id: chat_id} do
      chat = %{step: :waiting_for_death_date, name: "any", death_date: nil}
      update = %{"message" => %{"text" => "2025-05-11"}}

      result = Bot.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :waiting_for_reason
      assert result.death_date == "2025-05-11"
    end

    test "handles :waiting_for_reason step", %{key: key, chat_id: chat_id} do
      chat = %{step: :waiting_for_reason, name: "any", death_date: "any", reason: "accident"}
      update = %{"message" => %{"text" => "Accident"}}

      result = Bot.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :finished
      assert result.reason == "Accident"
    end

    test "handles :finished state, will removed later", %{key: key, chat_id: chat_id} do
      chat = %{step: :finished, name: "any", death_date: "any", reason: "any"}
      update = %{"message" => %{"text" => "Some text"}}

      result = Bot.process_message_from_user(key, update, chat, chat_id)

      assert result == chat
    end
  end

  describe "update_chats" do
    test "update chats" do
      updates = [
        %{
          "message" => %{
            "chat" => %{
              "first_name" => "Max",
              "id" => 1,
              "last_name" => "P",
              "type" => "private",
              "username" => "maxp"
            },
            "date" => 1_746_874_550,
            "entities" => [%{"length" => 5, "offset" => 0, "type" => "bot_command"}],
            "from" => %{
              "first_name" => "Max",
              "id" => 1,
              "is_bot" => false,
              "is_premium" => true,
              "language_code" => "en",
              "last_name" => "P",
              "username" => "maxp"
            },
            "message_id" => 177,
            "text" => "/start"
          },
          "update_id" => 597_970_406
        },
        %{
          "message" => %{
            "chat" => %{
              "first_name" => "Another",
              "id" => 2,
              "last_name" => "P",
              "type" => "private",
              "username" => "anotherp"
            },
            "date" => 1_746_874_551,
            "entities" => [%{"length" => 5, "offset" => 0, "type" => "bot_command"}],
            "from" => %{
              "first_name" => "Another",
              "id" => 2,
              "is_bot" => false,
              "is_premium" => true,
              "language_code" => "en",
              "last_name" => "P",
              "username" => "anotherp"
            },
            "message_id" => 178,
            "text" => "WHATEVER"
          },
          "update_id" => 597_970_407
        }
      ]

      key = "fake_telegram_token"

      chats = %{}

      new_chats = Bot.update_chats(key, updates, chats)

      new_chats
    end
  end
end
