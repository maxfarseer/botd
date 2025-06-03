ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Botd.Repo, :manual)

Mox.defmock(Botd.MockTelegramAPI, for: Botd.ChatBotAdapter)
Application.put_env(:botd, :telegram_chat, Botd.MockTelegramAPI)

Mox.defmock(Botd.MockFileHandler, for: Botd.FileHandlerAdapter)
Application.put_env(:botd, :file_handler, Botd.MockFileHandler)
