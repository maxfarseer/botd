ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Botd.Repo, :manual)

Mox.defmock(Botd.MockTelegramAPI, for: Botd.TelegramWTF)
Application.put_env(:botd, :telegram_wtf, Botd.MockTelegramAPI)
