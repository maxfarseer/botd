defmodule ChatTest do
  alias Botd.Chat
  alias Botd.TelegramMessagesFixture
  use Botd.DataCase, async: true

  describe "process_message_from_user/4" do
    setup do
      key = "dummy_key"
      chat_id = 12_345
      {:ok, key: key, chat_id: chat_id}
    end

    test "handles :waiting_for_start step", %{key: key, chat_id: chat_id} do
      chat = %Chat{step: :waiting_for_start}
      update = %{"message" => %{"text" => "/start"}}

      result = Chat.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :selected_action
    end

    test "handles action", %{key: key, chat_id: chat_id} do
      chat = %Chat{step: :selected_action}
      update = %{"message" => %{"text" => "Добавить"}}

      result = Chat.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :waiting_for_name
    end

    test "handles :waiting_for_name step", %{key: key, chat_id: chat_id} do
      chat = %Chat{step: :waiting_for_name, name: nil}
      update = %{"message" => %{"text" => "John Doe"}}

      result = Chat.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :waiting_for_death_date
      assert result.name == "John Doe"
    end

    test "handles :waiting_for_death_date step", %{key: key, chat_id: chat_id} do
      chat = %Chat{step: :waiting_for_death_date, name: "any", death_date: nil}
      update = %{"message" => %{"text" => "2025-05-11"}}

      result = Chat.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :waiting_for_reason
      assert result.death_date == ~D[2025-05-11]
    end

    test "handles :waiting_for_reason step", %{key: key, chat_id: chat_id} do
      chat = %Chat{step: :waiting_for_reason, name: "any", death_date: "any", reason: "accident"}
      update = %{"message" => %{"text" => "Accident"}}

      result = Chat.process_message_from_user(key, update, chat, chat_id)

      assert result.step == :waiting_for_photo
      assert result.reason == "Accident"
    end

    # This test require mocking. Looking for a solution / refactor
    # test "handles :waiting_for_photo step", %{key: key, chat_id: chat_id} do
    #   chat = %Chat{
    #     step: :waiting_for_photo,
    #     name: "any",
    #     death_date: "any",
    #     reason: "any",
    #     photo_url: nil
    #   }

    #   Botd.Chat
    #   |> expect(:get_file_url, fn ^key, "test_file_id" ->
    #     {:ok, "https://example.com/test.jpg"}
    #   end)

    #   Botd.FileHandler
    #   |> expect(:download_and_save_file, fn "https://example.com/test.jpg", _filename ->
    #     {:ok, "/uploads/test.jpg"}
    #   end)

    #   update = %{"message" => %{"photo" => [%{"file_id" => "photo_id"}]}}

    #   result = Chat.process_message_from_user(key, update, chat, chat_id)

    #   assert result.step == :finished
    #   assert result.photo_url == "test.jpg"
    # end

    test "handles :finished state, will removed later", %{key: key, chat_id: chat_id} do
      chat = %Chat{step: :finished, name: "any", death_date: "any", reason: "any"}
      update = %{"message" => %{"text" => "Some text"}}

      result = Chat.process_message_from_user(key, update, chat, chat_id)

      assert result == chat
      assert result.step == :finished
    end

    test "create_message_fixture creates a valid message structure as visciang/telegram v2.1.0 is using" do
      chat_id = 12_345
      date = 1_748_714_354
      message_id = 1
      text = "Hello, world!"
      update_id = 54_321

      message =
        TelegramMessagesFixture.create_message_fixture(
          chat_id,
          date,
          message_id,
          text,
          update_id
        )

      assert get_in(message, ["message", "chat", "id"]) == chat_id
      assert get_in(message, ["message", "date"]) == date
      assert get_in(message, ["message", "message_id"]) == message_id
      assert get_in(message, ["message", "text"]) == text
      assert get_in(message, ["update_id"]) == update_id
    end

    test "handles two chats in parallel and keeps their state separate", %{
      key: key
    } do
      chat1_id = 1
      chat2_id = 2
      chat1 = %Chat{chat_id: chat1_id, step: :waiting_for_name, name: nil}

      chat2 = %Chat{
        chat_id: chat2_id,
        step: :waiting_for_death_date,
        name: "John Doe",
        death_date: nil
      }

      message1 =
        TelegramMessagesFixture.create_message_fixture(
          chat1_id,
          1_748_714_354,
          1,
          "John Doe",
          54_321
        )

      message2 =
        TelegramMessagesFixture.create_message_fixture(
          chat2_id,
          1_748_714_355,
          2,
          "2025-05-11",
          54_322
        )

      result1 =
        Chat.process_message_from_user(key, message1, chat1, chat1_id)

      result2 =
        Chat.process_message_from_user(key, message2, chat2, chat2_id)

      assert result1.step == :waiting_for_death_date
      assert result2.step == :waiting_for_reason
      assert result1.chat_id != result2.chat_id
      assert result1.chat_id == chat1_id
      assert result2.chat_id == chat2_id
    end
  end

  describe "make_photo_set from telegram update" do
    setup do
      fixture = [
        %{
          "file_id" => "id1",
          "file_size" => 100,
          "file_unique_id" => "uniq-id-1",
          "height" => 90,
          "width" => 67
        },
        %{
          "file_id" => "id2",
          "file_size" => 200,
          "file_unique_id" => "uniq-id-2",
          "height" => 320,
          "width" => 240
        },
        %{
          "file_id" => "id3",
          "file_size" => 300,
          "file_unique_id" => "uniq-id-3",
          "height" => 800,
          "width" => 600
        },
        %{
          "file_id" => "id4",
          "file_size" => 400,
          "file_unique_id" => "uniq-id-4",
          "height" => 1280,
          "width" => 960
        }
      ]

      {:ok, fixture: fixture}
    end

    test "returns a map with up to 4 photos", %{fixture: fixture} do
      update = %{
        "message" => %{
          "photo" => fixture
        }
      }

      assert {:ok, photoset} = Chat.make_photo_set(update)
      assert photoset.tiny == %{file_id: "id1", file_size: 100}
      assert photoset.small == %{file_id: "id2", file_size: 200}
      assert photoset.medium == %{file_id: "id3", file_size: 300}
      assert photoset.large == %{file_id: "id4", file_size: 400}
      refute Map.has_key?(photoset, :extra)
    end

    test "returns a map with less than 4 photos", %{fixture: fixture} do
      update = %{
        "message" => %{
          "photo" => fixture |> Enum.take(2)
        }
      }

      assert {:ok, photoset} = Chat.make_photo_set(update)
      assert photoset.tiny == %{file_id: "id1", file_size: 100}
      assert photoset.small == %{file_id: "id2", file_size: 200}
      refute Map.has_key?(photoset, :medium)
      refute Map.has_key?(photoset, :large)
    end

    test "returns error when no photos are present" do
      update = %{"message" => %{}}
      assert {:error, "No photo found"} = Chat.make_photo_set(update)
    end
  end
end
