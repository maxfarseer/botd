# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Botd.Repo.insert!(%Botd.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Botd.Accounts

# Bot users — used by Telegram and VK bots to submit suggestions
bot_users = [
  %{email: "telegram@bot.com", password: "bot_placeholder_password_123!", role: :member},
  %{email: "vk@bot.com", password: "bot_placeholder_password_123!", role: :member}
]

for attrs <- bot_users do
  case Accounts.get_user_by_email(attrs.email) do
    nil -> Accounts.register_user(attrs)
    _existing -> :ok
  end
end
