defmodule BotdWeb.TelegramController do
  @moduledoc """
  This controller is used to handle Telegram bot interactions.

  The answer message is:
  Message: %{
    "chat" => %{
      "first_name" => "Max",
      "id" => 123456789,
      "last_name" => "P",
      "type" => "private",
      "username" => "test_username"
    },
    "date" => 1746525897,
    "from" => %{
      "first_name" => "Max",
      "id" => 123456789,
      "is_bot" => false,
      "is_premium" => true,
      "language_code" => "en",
      "last_name" => "P",
      "username" => "usetest_username"
    },
    "message_id" => 5,
    "text" => "About something..."
  }
  """
  use BotdWeb, :controller

  @telegram_token Application.compile_env(:botd, Botd.TelegramBot, telegramToken: "default_token")[
                    :telegramToken
                  ]

  # def playground(conn, _params) do
  #   {:ok, %{"first_name" => first_name, "username" => username}} =
  #     Telegram.Api.request(@telegram_token, "getMe")

  #   render(conn, :playground, info: %{first_name: first_name, username: username})
  # end

  def playground(conn, _params) do
    case Telegram.Api.request(@telegram_token, "getUpdates", offset: -1, timeout: 30) do
      {:ok, []} ->
        render(conn, :playground, info: %{first_name: "Unknown", text: "No updates"})

      {:ok,
       [
         %{
           "message" => %{
             "chat" => %{
               "id" => chat_id,
               "username" => username
             },
             "text" => text
           }
         }
         | _
       ]} ->
        keyboard = [
          ["A", "B"]
        ]

        keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}

        Telegram.Api.request(@telegram_token, "sendMessage",
          chat_id: chat_id,
          text: "Here a keyboard for #{chat_id}!",
          reply_markup: {:json, keyboard_markup}
        )

        render(conn, :playground, info: %{username: username, text: text})

      {:error, _reason} ->
        render(
          conn |> put_flash(:error, "Error update, ask developer to inspect the _reason"),
          :playground,
          info: %{first_name: "Unknown", text: "Error fetching updates"}
        )
    end
  end
end
