defmodule BotdWeb.TelegramController do
  use BotdWeb, :controller

  @telegram_token Application.compile_env(:botd, Botd.TelegramBot, telegramToken: "default_token")[
                    :telegramToken
                  ]

  def playground(conn, _params) do
    IO.inspect(@telegram_token, label: "Telegram Token")

    {:ok, %{"first_name" => first_name, "username" => username}} =
      IO.inspect(Telegram.Api.request(@telegram_token, "getMe"))

    IO.inspect(first_name)

    render(conn, :playground, info: %{first_name: first_name, username: username})
  end
end
