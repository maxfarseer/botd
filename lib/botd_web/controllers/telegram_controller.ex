defmodule BotdWeb.TelegramController do
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
      {:ok, message} ->
        IO.inspect(message)

        first_name =
          message
          |> List.first()
          |> Map.get("message")
          |> Map.get("from")
          |> Map.get("first_name")

        text =
          message
          |> List.first()
          |> Map.get("message")
          |> Map.get("text")

        render(conn, :playground, info: %{first_name: first_name, text: text})

      {:error, reason} ->
        IO.inspect(reason, label: "Error fetching updates from Telegram bot")
        render(conn, :playground, info: %{first_name: "Unknown", text: "Error fetching updates"})
    end
  end
end
