ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Botd.Repo, :manual)

Mox.defmock(Botd.Adapters.MockTelegramAPI, for: Botd.Adapters.ChatBotAdapter)
Application.put_env(:botd, :telegram_chat, Botd.Adapters.MockTelegramAPI)

Mox.defmock(Botd.Adapters.MockFileHandler, for: Botd.Adapters.FileHandlerAdapter)
Application.put_env(:botd, :file_handler, Botd.Adapters.MockFileHandler)
