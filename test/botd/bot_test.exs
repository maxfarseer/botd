defmodule Botd.BotTest do
  alias Botd.Bot
  use Botd.DataCase, async: true

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

      initial_chats = %{}

      updated_chats = Bot.update_chats(key, updates, initial_chats)

      updated_chats
    end
  end
end
