defmodule ChatTest do
  alias Botd.Chat
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
  end
end
