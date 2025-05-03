defmodule BotdWeb.TelegramController do
  use BotdWeb, :controller

  @telegram_token Application.compile_env(:botd, Botd.TelegramBot, telegramToken: "default_token")[
                    :telegramToken
                  ]

  def playground(conn, _params) do
    {:ok, %{"first_name" => first_name, "username" => username}} =
      Telegram.Api.request(@telegram_token, "getMe")

    render(conn, :playground, info: %{first_name: first_name, username: username})
  end
end
