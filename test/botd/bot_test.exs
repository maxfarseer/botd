defmodule Botd.BotTest do
  use Botd.DataCase, async: true
  alias Botd.Bot

  def initialise_state do
    %{
      last_seen: 0,
      chats: %{}
    }
  end

  describe "bot finite state machine" do
    test "User started a dialogue" do
      chat_id = "1"

      state = initialise_state()

      updated_chats = Bot.update_chat(state, :start, chat_id, "/start")

      assert updated_chats == %{
               chat_id => %{
                 state: :waiting_for_name,
                 name: nil,
                 death_date: nil,
                 reason: nil
               }
             }
    end

    test "User typed the name" do
      chat_id = "1"
      text = "John Doe"
      action = :provide_name

      state = %{
        chats: %{
          chat_id => %{
            state: :waiting_for_name,
            name: nil,
            death_date: nil,
            reason: nil
          }
        }
      }

      new_state = Bot.update_chat(state, action, chat_id, text)

      assert new_state == %{
               chat_id => %{
                 state: :waiting_for_death_date,
                 name: text,
                 death_date: nil,
                 reason: nil
               }
             }
    end

    test "User typed the date of the death" do
      chat_id = "1"
      text = "2023-10-01"
      action = :provide_death_date

      state = %{
        chats: %{
          chat_id => %{
            state: :waiting_for_death_date,
            name: "John Doe",
            death_date: nil,
            reason: nil
          }
        }
      }

      new_state = Bot.update_chat(state, action, chat_id, text)

      assert new_state == %{
               chat_id => %{
                 state: :waiting_for_reason,
                 name: "John Doe",
                 death_date: text,
                 reason: nil
               }
             }
    end

    test "User typed the reason of the death" do
      chat_id = "1"
      text = "Natural causes"
      action = :provide_reason

      state = %{
        chats: %{
          chat_id => %{
            state: :waiting_for_reason,
            name: "John Doe",
            death_date: "2023-10-01",
            reason: nil
          }
        }
      }

      new_state = Bot.update_chat(state, action, chat_id, text)

      assert new_state == %{
               chat_id => %{
                 state: :finished,
                 name: "John Doe",
                 death_date: "2023-10-01",
                 reason: text
               }
             }
    end

    test "unknown command do not remove correct values" do
      chat_id = "1"
      text = "whatever"
      action = :oops

      state = %{
        chats: %{
          chat_id => %{
            state: :waiting_for_reason,
            name: "John Doe",
            death_date: "2023-10-01",
            reason: nil
          }
        }
      }

      new_state = Bot.update_chat(state, action, chat_id, text)

      assert new_state == %{
               chat_id => %{
                 state: :waiting_for_reason,
                 name: "John Doe",
                 death_date: "2023-10-01",
                 reason: nil
               }
             }
    end

    test "update chats" do
      update = [
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
            "text" => "/stop"
          },
          "update_id" => 597_970_407
        }
      ]

      chats = %{}

      new_chats = Bot.update_chats(update, chats)
      IO.inspect(new_chats)
    end
  end
end
