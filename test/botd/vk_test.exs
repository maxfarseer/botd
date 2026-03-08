defmodule Botd.VKTest do
  use Botd.DataCase, async: true

  alias Botd.AccountsFixtures
  alias Botd.Suggestions
  alias Botd.VK

  setup do
    vk_bot_user = AccountsFixtures.user_fixture(%{email: "vk@bot.com", role: :member})
    {:ok, vk_bot_user: vk_bot_user}
  end

  describe "process_event/1" do
    test "ignores non-wall_post_new events" do
      assert :ok = VK.process_event(%{"type" => "message_new", "object" => %{}})
      assert :ok = VK.process_event(%{"type" => "group_join", "object" => %{}})
    end

    test "ignores wall posts that are not suggestions" do
      event = %{
        "type" => "wall_post_new",
        "object" => %{
          "id" => 1,
          "post_type" => "post",
          "text" => "Имя: Тест\nДата: 01.01.2024",
          "owner_id" => -123_456
        }
      }

      assert :ok = VK.process_event(event)
      assert Suggestions.list_pending_suggestions() == []
    end
  end

  describe "process_event/1 with wall_post_new suggest" do
    test "creates a suggestion from a valid template post", %{vk_bot_user: vk_bot_user} do
      event =
        suggested_post_event(%{
          "text" => "Имя: Иванов Иван\nДата: 01.01.2024\nМесто: Москва\nПричина: онкология"
        })

      assert :ok = VK.process_event(event)

      [suggestion] = Suggestions.list_pending_suggestions()
      assert suggestion.name == "Иванов Иван"
      assert suggestion.death_date == ~D[2024-01-01]
      assert suggestion.place == "Москва"
      assert suggestion.notes == "онкология"
      assert suggestion.source == "vk"
      assert suggestion.vk_post_id == 789
      assert suggestion.vk_owner_id == -123_456
      assert suggestion.user_id == vk_bot_user.id
    end

    test "parses DD.MM.YYYY date format" do
      event = suggested_post_event(%{"text" => "Имя: Тест Тестов\nДата: 15.03.2024"})

      assert :ok = VK.process_event(event)

      [suggestion] = Suggestions.list_pending_suggestions()
      assert suggestion.death_date == ~D[2024-03-15]
    end

    test "parses ISO8601 date format" do
      event = suggested_post_event(%{"text" => "Имя: Тест Тестов\nДата: 2024-03-15"})

      assert :ok = VK.process_event(event)

      [suggestion] = Suggestions.list_pending_suggestions()
      assert suggestion.death_date == ~D[2024-03-15]
    end

    test "skips post when name is missing" do
      event = suggested_post_event(%{"text" => "Дата: 01.01.2024\nМесто: Москва"})

      assert :ok = VK.process_event(event)
      assert Suggestions.list_pending_suggestions() == []
    end

    test "skips post when date is missing" do
      event = suggested_post_event(%{"text" => "Имя: Тест Тестов\nМесто: Москва"})

      assert :ok = VK.process_event(event)
      assert Suggestions.list_pending_suggestions() == []
    end

    test "skips post when date is invalid" do
      event = suggested_post_event(%{"text" => "Имя: Тест Тестов\nДата: not-a-date"})

      assert :ok = VK.process_event(event)
      assert Suggestions.list_pending_suggestions() == []
    end

    test "extracts photo URL from attachments" do
      event =
        suggested_post_event(%{
          "text" => "Имя: Тест Тестов\nДата: 01.01.2024",
          "attachments" => [
            %{
              "type" => "photo",
              "photo" => %{
                "sizes" => [
                  %{"url" => "https://vk.com/photo_small.jpg", "width" => 100, "height" => 75},
                  %{"url" => "https://vk.com/photo_large.jpg", "width" => 800, "height" => 600}
                ]
              }
            }
          ]
        })

      assert :ok = VK.process_event(event)

      [suggestion] = Suggestions.list_pending_suggestions()
      assert suggestion.photo_url == "https://vk.com/photo_large.jpg"
    end

    test "extracts multiple photos — first as photo_url, rest as photos array" do
      event =
        suggested_post_event(%{
          "text" => "Имя: Тест Тестов\nДата: 01.01.2024",
          "attachments" => [
            %{
              "type" => "photo",
              "photo" => %{
                "sizes" => [
                  %{"url" => "https://vk.com/photo1.jpg", "width" => 800, "height" => 600}
                ]
              }
            },
            %{
              "type" => "photo",
              "photo" => %{
                "sizes" => [
                  %{"url" => "https://vk.com/photo2.jpg", "width" => 800, "height" => 600}
                ]
              }
            }
          ]
        })

      assert :ok = VK.process_event(event)

      [suggestion] = Suggestions.list_pending_suggestions()
      assert suggestion.photo_url == "https://vk.com/photo1.jpg"
      assert suggestion.photos == ["https://vk.com/photo2.jpg"]
    end

    test "ignores non-photo attachments" do
      event =
        suggested_post_event(%{
          "text" => "Имя: Тест Тестов\nДата: 01.01.2024",
          "attachments" => [
            %{"type" => "link", "link" => %{"url" => "https://example.com"}}
          ]
        })

      assert :ok = VK.process_event(event)

      [suggestion] = Suggestions.list_pending_suggestions()
      assert suggestion.photo_url == nil
      assert suggestion.photos == [] or is_nil(suggestion.photos)
    end

    test "place and cause are optional" do
      event = suggested_post_event(%{"text" => "Имя: Тест Тестов\nДата: 01.01.2024"})

      assert :ok = VK.process_event(event)

      [suggestion] = Suggestions.list_pending_suggestions()
      assert suggestion.place == nil
      assert suggestion.notes == nil
    end
  end

  defp suggested_post_event(overrides) do
    object =
      Map.merge(
        %{
          "id" => 789,
          "post_type" => "suggest",
          "from_id" => 111_222,
          "owner_id" => -123_456,
          "text" => "Имя: Тест\nДата: 01.01.2024"
        },
        overrides
      )

    %{"type" => "wall_post_new", "object" => object}
  end
end
